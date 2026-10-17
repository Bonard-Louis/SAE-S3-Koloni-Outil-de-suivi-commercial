-- =============================================================================
-- KOLONI CRM - Triggers et fonctions
-- Historique des statuts, contrôle du positionnement et du qualificateur,
-- alimentation du journal d'actions.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- TRIGGER : historisation automatique des changements de statut
-- -----------------------------------------------------------------------------
-- Garantit EF-08 (historique complet et daté, avec auteur) même pour une
-- écriture SQL directe (agent IA, script) : toute mise à jour de
-- opportunite.statut doit s'accompagner d'un app.current_membre_id valide,
-- sans quoi la transaction échoue plutôt que de silencieusement perdre la trace.

CREATE FUNCTION fn_opportunite_historique_statut() RETURNS TRIGGER AS $$
DECLARE
    v_auteur_id BIGINT;
BEGIN
    IF NEW.statut IS DISTINCT FROM OLD.statut THEN
        -- NULLIF : sur une connexion déjà utilisée, la variable vaut '' et non NULL, et ''::BIGINT lève une erreur
        v_auteur_id := NULLIF(current_setting('app.current_membre_id', true), '')::BIGINT;

        IF v_auteur_id IS NULL THEN
            RAISE EXCEPTION
                'app.current_membre_id doit être défini avant tout changement de statut (SET LOCAL app.current_membre_id = ...)';
        END IF;

        INSERT INTO historique_statut (opportunite_id, ancien_statut, nouveau_statut, motif, date_relance, auteur_id)
        VALUES (NEW.id, OLD.statut, NEW.statut,
                CASE WHEN NEW.statut = 'perdu' THEN NEW.raison_perte END,
                CASE WHEN NEW.statut = 'en_pause' THEN NEW.date_relance END,
                v_auteur_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_opportunite_historique_statut() IS
    'Alimente historique_statut à chaque changement de opportunite.statut. Exige que la transaction ait défini app.current_membre_id (SET LOCAL app.current_membre_id = ''<id>''), jamais un SET de session avec un pool de connexions.';

CREATE TRIGGER trg_opportunite_historique_statut
    AFTER UPDATE OF statut ON opportunite
    FOR EACH ROW
    EXECUTE FUNCTION fn_opportunite_historique_statut();

CREATE FUNCTION fn_opportunite_historique_statut_creation() RETURNS TRIGGER AS $$
DECLARE
    v_auteur_id BIGINT;
BEGIN
    -- Auteur = membre connecté ; à défaut, celui qui a saisi l'opportunité, puis son apporteur
    v_auteur_id := COALESCE(NULLIF(current_setting('app.current_membre_id', true), '')::BIGINT, NEW.saisi_par_id, NEW.apporteur_id);

    INSERT INTO historique_statut (opportunite_id, ancien_statut, nouveau_statut, motif, date_relance, auteur_id)
    VALUES (NEW.id, NULL, NEW.statut,
            CASE WHEN NEW.statut = 'perdu' THEN NEW.raison_perte END,
            CASE WHEN NEW.statut = 'en_pause' THEN NEW.date_relance END,
            v_auteur_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_opportunite_historique_statut_creation() IS
    'Crée la première ligne d''historique à la publication d''une opportunité (ancien_statut NULL).';

CREATE TRIGGER trg_opportunite_historique_statut_creation
    AFTER INSERT ON opportunite
    FOR EACH ROW
    EXECUTE FUNCTION fn_opportunite_historique_statut_creation();

-- -----------------------------------------------------------------------------
-- TRIGGER : positionnement réservé aux opportunités en Signal ou Matching
-- -----------------------------------------------------------------------------
-- EF-15 / recueil 3.1 : "plusieurs membres peuvent se positionner sur une
-- même opportunité tant qu'elle est en Signal ou en Matching".

CREATE FUNCTION fn_positionnement_verifie_statut_opportunite() RETURNS TRIGGER AS $$
DECLARE
    v_statut VARCHAR(20);
BEGIN
    SELECT statut INTO v_statut FROM opportunite WHERE id = NEW.opportunite_id;

    IF v_statut NOT IN ('signal', 'matching') THEN
        RAISE EXCEPTION
            'Positionnement impossible : l''opportunité % est au statut % (seuls signal et matching acceptent un nouveau positionnement)',
            NEW.opportunite_id, v_statut;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_positionnement_verifie_statut_opportunite() IS
    'Bloque la création d''un positionnement si l''opportunité n''est pas au statut signal ou matching (EF-15).';

CREATE TRIGGER trg_positionnement_verifie_statut_opportunite
    BEFORE INSERT ON positionnement
    FOR EACH ROW
    EXECUTE FUNCTION fn_positionnement_verifie_statut_opportunite();

-- -----------------------------------------------------------------------------
-- TRIGGER : la qualification est validée par l'apporteur ou par un administrateur
-- -----------------------------------------------------------------------------
-- Recueil 3.1 : le passage de Signal à Matching résulte d'une validation explicite,
-- réservée à l'apporteur et aux administrateurs. Un CHECK ne pouvant pas lire une autre
-- table, ce trigger vérifie le qualificateur au moment où il est posé ou changé.
-- Une qualification déjà posée n'est pas remise en cause si son auteur est désactivé ensuite.

CREATE FUNCTION fn_opportunite_verifie_qualificateur() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.qualifiee_par_id IS NOT NULL
       AND (TG_OP = 'INSERT' OR NEW.qualifiee_par_id IS DISTINCT FROM OLD.qualifiee_par_id) THEN
        IF NOT EXISTS (
            SELECT 1 FROM membre m
            WHERE m.id = NEW.qualifiee_par_id
              AND m.actif
              AND (m.id = NEW.apporteur_id OR m.role = 'administrateur')
        ) THEN
            RAISE EXCEPTION
                'La qualification doit être validée par l''apporteur de l''opportunité ou par un administrateur actif';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_opportunite_verifie_qualificateur() IS
    'Refuse un qualificateur (qualifiee_par_id) qui n''est ni l''apporteur de l''opportunité ni un administrateur, ou dont le compte est désactivé. Ne contrôle que la pose ou le changement du qualificateur.';

CREATE TRIGGER trg_opportunite_verifie_qualificateur
    BEFORE INSERT OR UPDATE OF qualifiee_par_id ON opportunite
    FOR EACH ROW
    EXECUTE FUNCTION fn_opportunite_verifie_qualificateur();

-- -----------------------------------------------------------------------------
-- TRIGGERS : alimentation automatique du journal d'actions
-- -----------------------------------------------------------------------------
-- L'auteur est le membre posé par SET LOCAL app.current_membre_id dans la transaction. 
-- Pour une note, un positionnement ou une sollicitation, la ligne porte déjà son auteur, 
-- qui sert de repli. Pour un contact, une entreprise ou un profil extérieur, 
-- rien n'en porte : l'écriture est refusée sans auteur.
-- Les changements de statut ne passent pas par ici : historique_statut s'en charge.

CREATE FUNCTION fn_membre_courant(p_repli BIGINT DEFAULT NULL) RETURNS BIGINT AS $$
DECLARE
    v_membre_id BIGINT;
BEGIN
    -- NULLIF : sur une connexion déjà utilisée, la variable vaut '' et non NULL
    v_membre_id := COALESCE(NULLIF(current_setting('app.current_membre_id', true), '')::BIGINT, p_repli);

    IF v_membre_id IS NULL THEN
        RAISE EXCEPTION
            'app.current_membre_id doit être défini avant cette écriture (SET LOCAL app.current_membre_id = ...)';
    END IF;

    RETURN v_membre_id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION fn_membre_courant(BIGINT) IS
    'Membre qui agit : celui de la transaction (SET LOCAL app.current_membre_id), à défaut le repli passé par le trigger. Lève une exception si aucun des deux n''est connu.';

-- Positionnement : ajout, puis changement d'état (présenté, retenu, écarté, retiré)
CREATE FUNCTION fn_journal_positionnement() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO journal_action (opportunite_id, auteur_id, type_action, commentaire)
        VALUES (NEW.opportunite_id, fn_membre_courant(NEW.membre_id), 'positionnement', 'Positionnement ajouté');
    ELSIF NEW.etat IS DISTINCT FROM OLD.etat THEN
        INSERT INTO journal_action (opportunite_id, auteur_id, type_action, commentaire)
        VALUES (NEW.opportunite_id, fn_membre_courant(NEW.membre_id),
                CASE WHEN NEW.etat = 'presente' THEN 'presentation_profil' ELSE 'positionnement' END,
                CASE WHEN NEW.etat = 'presente' THEN 'Profil présenté' ELSE 'Positionnement : ' || NEW.etat END);
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_positionnement
    AFTER INSERT OR UPDATE OF etat ON positionnement
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_positionnement();

-- Note ajoutée sur une opportunité
CREATE FUNCTION fn_journal_note() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO journal_action (opportunite_id, auteur_id, type_action, commentaire)
    VALUES (NEW.opportunite_id, fn_membre_courant(NEW.auteur_id), 'note', 'Note ajoutée');

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_note
    AFTER INSERT ON note
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_note();

-- Profil extérieur sollicité pour une opportunité
CREATE FUNCTION fn_journal_sollicitation() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO journal_action (opportunite_id, profil_exterieur_id, auteur_id, type_action, commentaire)
    VALUES (NEW.opportunite_id, NEW.profil_exterieur_id, fn_membre_courant(NEW.sollicite_par_id),
            'profil_exterieur_contacte', 'Profil extérieur sollicité');

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_sollicitation
    AFTER INSERT ON profil_exterieur_opportunite
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_sollicitation();

-- Fiche d'un profil extérieur modifiée (une modification qui ne change rien n'est pas journalisée)
CREATE FUNCTION fn_journal_profil_exterieur() RETURNS TRIGGER AS $$
BEGIN
    IF NEW IS DISTINCT FROM OLD THEN
        INSERT INTO journal_action (profil_exterieur_id, auteur_id, type_action, commentaire)
        VALUES (NEW.id, fn_membre_courant(), 'profil_exterieur_modifie', 'Profil extérieur modifié');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_profil_exterieur
    AFTER UPDATE ON profil_exterieur
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_profil_exterieur();

-- Contact créé ou modifié (hors opportunité : opportunite_id reste vide)
CREATE FUNCTION fn_journal_contact() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO journal_action (contact_id, auteur_id, type_action, commentaire)
        VALUES (NEW.id, fn_membre_courant(), 'contact_cree_modifie', 'Contact créé');
    ELSIF NEW IS DISTINCT FROM OLD THEN
        INSERT INTO journal_action (contact_id, auteur_id, type_action, commentaire)
        VALUES (NEW.id, fn_membre_courant(), 'contact_cree_modifie', 'Contact modifié');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_contact
    AFTER INSERT OR UPDATE ON contact
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_contact();

-- Contact rattaché à une opportunité, ou retiré de celle-ci (correction d'un rattachement)
CREATE FUNCTION fn_journal_opportunite_contact() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO journal_action (opportunite_id, contact_id, auteur_id, type_action, commentaire)
        VALUES (NEW.opportunite_id, NEW.contact_id, fn_membre_courant(), 'contact_cree_modifie',
                'Contact rattaché à l''opportunité');
    ELSE
        INSERT INTO journal_action (opportunite_id, contact_id, auteur_id, type_action, commentaire)
        VALUES (OLD.opportunite_id, OLD.contact_id, fn_membre_courant(), 'contact_cree_modifie',
                'Contact retiré de l''opportunité');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_opportunite_contact
    AFTER INSERT OR DELETE ON opportunite_contact
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_opportunite_contact();

-- Entreprise cliente créée ou modifiée
CREATE FUNCTION fn_journal_entreprise_cliente() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO journal_action (entreprise_cliente_id, auteur_id, type_action, commentaire)
        VALUES (NEW.id, fn_membre_courant(), 'entreprise_cree_modifiee', 'Entreprise créée');
    ELSIF NEW IS DISTINCT FROM OLD THEN
        INSERT INTO journal_action (entreprise_cliente_id, auteur_id, type_action, commentaire)
        VALUES (NEW.id, fn_membre_courant(), 'entreprise_cree_modifiee', 'Entreprise modifiée');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_entreprise_cliente
    AFTER INSERT OR UPDATE ON entreprise_cliente
    FOR EACH ROW
    EXECUTE FUNCTION fn_journal_entreprise_cliente();
COMMIT;
