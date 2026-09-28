-- =============================================================================
-- KOLONI CRM - Schéma initial de la base de données
-- Migration 001 : création du schéma complet
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- MEMBRE
-- -----------------------------------------------------------------------------

CREATE TABLE membre (
    id                BIGSERIAL PRIMARY KEY,
    nom               VARCHAR(100)  NOT NULL,
    prenom            VARCHAR(100)  NOT NULL,
    mail              VARCHAR(255)  NOT NULL,
    telephone         VARCHAR(30),
    notes             TEXT,
    role              VARCHAR(20)   NOT NULL DEFAULT 'membre',
    ville             VARCHAR(100),
    disponibilite     VARCHAR(20)   NOT NULL DEFAULT 'en_recherche',
    date_fin_mission  DATE,
    actif             BOOLEAN       NOT NULL DEFAULT TRUE,
    date_creation     TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT uq_membre_mail UNIQUE (mail),
    CONSTRAINT chk_membre_role
        CHECK (role IN ('administrateur', 'membre')),
    CONSTRAINT chk_membre_disponibilite
        CHECK (disponibilite IN ('en_recherche', 'en_mission')),
    CONSTRAINT chk_membre_date_fin_mission
        CHECK (disponibilite = 'en_mission' OR date_fin_mission IS NULL),
    CONSTRAINT chk_membre_ville_format
        CHECK (ville IS NULL OR length(btrim(ville)) > 0)
);

COMMENT ON TABLE membre IS
    'Freelance du collectif Koloni, avec un compte personnel. Un membre désactivé garde toutes ses traces (positionnements, notes, actions).';
COMMENT ON COLUMN membre.role IS
    'Droits d''action : administrateur ou membre. Un administrateur reste un freelance et peut être apporteur/moteur.';
COMMENT ON COLUMN membre.disponibilite IS
    'en_recherche ou en_mission. Permet au membre de rendre visible sa disponibilité auprès de tout le collectif.';
COMMENT ON COLUMN membre.date_fin_mission IS
    'Renseignée uniquement quand disponibilite = en_mission (cf. chk_membre_date_fin_mission).';
COMMENT ON COLUMN membre.actif IS
    'FALSE = compte désactivé (ex-membre du collectif). Ne jamais supprimer la ligne : conserve l''historique de ses actions.';

-- -----------------------------------------------------------------------------
-- TECHNOLOGIE
-- -----------------------------------------------------------------------------

CREATE TABLE technologie (
    id    BIGSERIAL PRIMARY KEY,
    nom   VARCHAR(100) NOT NULL,

    CONSTRAINT uq_technologie_nom UNIQUE (nom)
);

COMMENT ON TABLE technologie IS
    'Liste de valeurs réutilisable (ex. Talend, Power BI, Python), utilisée par les opportunités et les profils extérieurs, et servant de filtre.';

-- -----------------------------------------------------------------------------
-- ENTREPRISE CLIENTE
-- -----------------------------------------------------------------------------

CREATE TABLE entreprise_cliente (
    id             BIGSERIAL PRIMARY KEY,
    nom            VARCHAR(255) NOT NULL,
    secteur        VARCHAR(150),
    taille         VARCHAR(50),
    ville          VARCHAR(100),
    date_creation  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT uq_entreprise_cliente_nom UNIQUE (nom)
);

COMMENT ON TABLE entreprise_cliente IS
    'Société (ESN ou client direct) à laquelle sont rattachés les contacts. Réutilisable d''une opportunité à l''autre, sert au filtre "société du contact".';
COMMENT ON COLUMN entreprise_cliente.nom IS
    'Unique : évite la création de doublons lors de la saisie répétée d''une même société par différents membres.';

-- -----------------------------------------------------------------------------
-- CONTACT
-- -----------------------------------------------------------------------------

CREATE TABLE contact (
    id                     BIGSERIAL PRIMARY KEY,
    nom                    VARCHAR(100)  NOT NULL,
    prenom                 VARCHAR(100)  NOT NULL,
    role                   VARCHAR(150),
    entreprise_cliente_id  BIGINT REFERENCES entreprise_cliente(id) ON DELETE RESTRICT,
    mail                   VARCHAR(255),
    telephone              VARCHAR(30),
    date_creation          TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_contact_moyen_contact
        CHECK (mail IS NOT NULL OR telephone IS NOT NULL)
);

COMMENT ON TABLE contact IS
    'Personne côté client (commercial, DSI, responsable data...), rattachée à une entreprise cliente. Distinct des profils extérieurs (freelances hors collectif). Un même contact peut être lié à plusieurs opportunités au fil du temps.';
COMMENT ON COLUMN contact.role IS
    'Fonction chez le client (ex. commercial, responsable data, DSI).';
COMMENT ON COLUMN contact.mail IS
    'Au moins un moyen de contact (mail ou téléphone) est requis, cf. chk_contact_moyen_contact.';
COMMENT ON COLUMN contact.telephone IS
    'Au moins un moyen de contact (mail ou téléphone) est requis, cf. chk_contact_moyen_contact.';
COMMENT ON COLUMN contact.entreprise_cliente_id IS
    'Nullable : le contact peut être saisi avant que son entreprise soit connue. À renseigner dès que possible, recommandé mais non bloquant.';

CREATE INDEX idx_contact_entreprise ON contact(entreprise_cliente_id);

-- -----------------------------------------------------------------------------
-- PROFIL EXTERIEUR (contacté hors collectif)
-- -----------------------------------------------------------------------------

CREATE TABLE profil_exterieur (
    id                  BIGSERIAL PRIMARY KEY,
    nom                 VARCHAR(100)  NOT NULL,
    prenom              VARCHAR(100)  NOT NULL,
    moyen_contact       VARCHAR(255)  NOT NULL,
    niveau              VARCHAR(20),
    experiences_cles    TEXT,
    ville               VARCHAR(100),
    disponibilite       VARCHAR(100),
    tjm                 NUMERIC(8,2),
    date_sollicitation  DATE          NOT NULL DEFAULT CURRENT_DATE,
    issue               VARCHAR(30),
    auteur_id           BIGINT        NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_creation       TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_profil_ext_niveau
        CHECK (niveau IS NULL OR niveau IN ('operationnel', 'senior', 'expert')),
    CONSTRAINT chk_profil_ext_issue
        CHECK (issue IS NULL OR issue IN (
            'presente', 'retenu', 'ecarte_client', 'indisponible',
            'sans_reponse_profil', 'sans_retour_client'
        ))
);

COMMENT ON TABLE profil_exterieur IS
    'Fiche technique d''un profil freelance contacté hors collectif par un moteur. Peut être lié à plusieurs opportunités. Pas de suppression, pas de pièce jointe/CV dans cette version.';
COMMENT ON COLUMN profil_exterieur.moyen_contact IS
    'Mail, téléphone ou autre canal. Obligatoire : un profil non recontactable n''a pas d''intérêt pour la base de profils qualifiés (cf. UC13).';
COMMENT ON COLUMN profil_exterieur.niveau IS
    'operationnel, senior ou expert, ou NULL si non renseigné (cf. chk_profil_ext_niveau).';
COMMENT ON COLUMN profil_exterieur.ville IS
    'Localisation du profil.';
COMMENT ON COLUMN profil_exterieur.disponibilite IS
    'Texte libre : disponible immédiatement, à partir d''une date...';
COMMENT ON COLUMN profil_exterieur.tjm IS
    'Taux journalier moyen souhaité par le profil.';
COMMENT ON COLUMN profil_exterieur.date_sollicitation IS
    'Date du contact avec le profil.';
COMMENT ON COLUMN profil_exterieur.auteur_id IS
    'Membre qui a contacté et saisi ce profil (moteur, administrateur ou non).';
COMMENT ON COLUMN profil_exterieur.issue IS
    'Résultat de la sollicitation. Voir chk_profil_ext_issue pour les valeurs autorisées.';

-- -----------------------------------------------------------------------------
-- OPPORTUNITE
-- -----------------------------------------------------------------------------

CREATE TABLE opportunite (
    id                            BIGSERIAL PRIMARY KEY,
    titre                         VARCHAR(255)  NOT NULL,
    source                        VARCHAR(20),
    temperature                   VARCHAR(10),
    type_mission                  VARCHAR(50),
    niveau_recherche              VARCHAR(20),
    client_final_nom              VARCHAR(255),
    client_final_secteur          VARCHAR(150),
    client_final_taille           VARCHAR(50),
    apporteur_id                  BIGINT        NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    saisi_par_id                  BIGINT        REFERENCES membre(id) ON DELETE RESTRICT,
    moteur_id                     BIGINT        REFERENCES membre(id) ON DELETE RESTRICT,
    preneur_membre_id             BIGINT        REFERENCES membre(id) ON DELETE RESTRICT,
    preneur_profil_exterieur_id   BIGINT        REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    tjm_annonce                   NUMERIC(8,2),
    tjm_client                    NUMERIC(8,2),
    tjm_preneur                   NUMERIC(8,2),
    duree_annoncee_mois           NUMERIC(5,1),
    nombre_jours                  INTEGER,
    charge                        VARCHAR(50),
    ville                         VARCHAR(100),
    mode                          VARCHAR(20),
    timing                        VARCHAR(20),
    mode_candidature              VARCHAR(30),
    mode_candidature_precision    VARCHAR(255),
    niveau_diffusion              VARCHAR(20)   NOT NULL DEFAULT 'reseau_perso',
    date_ouverture_exterieur      DATE,
    statut                        VARCHAR(20)   NOT NULL DEFAULT 'signal',
    date_signal                   DATE          NOT NULL DEFAULT CURRENT_DATE,
    date_cloture                  DATE,
    date_relance                  DATE,
    raison_perte                  TEXT,
    date_creation                 TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_opp_source
        CHECK (source IS NULL OR source IN ('client', 'commercial', 'contact')),
    CONSTRAINT chk_opp_temperature
        CHECK (temperature IS NULL OR temperature IN ('chaud', 'tiede')),
    CONSTRAINT chk_opp_niveau_recherche
        CHECK (niveau_recherche IS NULL OR niveau_recherche IN ('operationnel', 'senior', 'expert')),
    CONSTRAINT chk_opp_mode
        CHECK (mode IS NULL OR mode IN ('teletravail', 'hybride', 'presentiel')),
    CONSTRAINT chk_opp_timing
        CHECK (timing IS NULL OR timing IN ('urgent', 'moins_1_mois', 'plus_1_mois')),
    CONSTRAINT chk_opp_mode_candidature
        CHECK (mode_candidature IS NULL OR mode_candidature IN
               ('via_apporteur', 'contact_direct_recruteur', 'via_moteur')),
    CONSTRAINT chk_opp_niveau_diffusion
        CHECK (niveau_diffusion IN ('libre', 'reseau_perso', 'interne_strict')),
    CONSTRAINT chk_opp_statut
        CHECK (statut IN ('signal', 'matching', 'propose', 'en_discussion',
                           'signe', 'perdu', 'en_pause')),
    CONSTRAINT chk_opp_raison_perte_obligatoire
        CHECK (statut <> 'perdu' OR raison_perte IS NOT NULL),
    CONSTRAINT chk_opp_date_relance_obligatoire
        CHECK (statut <> 'en_pause' OR date_relance IS NOT NULL),
    CONSTRAINT chk_opp_cloture_obligatoire
        CHECK (statut NOT IN ('signe', 'perdu') OR date_cloture IS NOT NULL),
    CONSTRAINT chk_opp_signe_complet
        CHECK (
            statut <> 'signe'
            OR (
                (preneur_membre_id IS NOT NULL OR preneur_profil_exterieur_id IS NOT NULL)
                AND tjm_preneur IS NOT NULL
                AND nombre_jours IS NOT NULL
            )
        ),
    CONSTRAINT chk_opp_preneur_exclusif
        CHECK (NOT (preneur_membre_id IS NOT NULL AND preneur_profil_exterieur_id IS NOT NULL)),
    CONSTRAINT chk_opp_nombre_jours_positif
        CHECK (nombre_jours IS NULL OR nombre_jours >= 0)
);

COMMENT ON TABLE opportunite IS
    'Opportunité commerciale : publiée même incomplète (statut signal), suit un cycle de vie en 7 statuts jusqu''à signature ou perte. Jamais supprimée physiquement.';
COMMENT ON COLUMN opportunite.source IS
    'Qui porte le besoin côté client : client, commercial (ESN) ou contact.';
COMMENT ON COLUMN opportunite.temperature IS
    'Niveau de maturité de l''opportunité : chaud, tiede, ou NULL si non renseigné (cf. chk_opp_temperature). Facultatif, non requis pour la qualification Signal → Matching.';
COMMENT ON COLUMN opportunite.client_final_nom IS
    'Entreprise où se déroule la mission, si connue. Facultatif (souvent inconnu si le besoin passe par une ESN) : ne bloque jamais la publication. Distinct de la société du contact (cf. table contact).';
COMMENT ON COLUMN opportunite.apporteur_id IS
    'Membre qui amène l''opportunité. La relation client passe par lui, le moteur ou directement le candidat, selon mode_candidature.';
COMMENT ON COLUMN opportunite.saisi_par_id IS
    'Membre qui a créé la fiche dans l''outil, uniquement renseigné quand il diffère de l''apporteur.';
COMMENT ON COLUMN opportunite.moteur_id IS
    'Personne qui recherche un profil hors collectif pour cette opportunité, le cas échéant.';
COMMENT ON COLUMN opportunite.preneur_membre_id IS
    'Freelance du collectif retenu, renseigné à la clôture. Exclusif avec preneur_profil_exterieur_id (cf. chk_opp_preneur_exclusif).';
COMMENT ON COLUMN opportunite.preneur_profil_exterieur_id IS
    'Profil extérieur retenu, renseigné à la clôture. Exclusif avec preneur_membre_id (cf. chk_opp_preneur_exclusif).';
COMMENT ON COLUMN opportunite.tjm_annonce IS
    'Ce que touche le candidat, annoncé tel quel aux membres (champ du template de publication).';
COMMENT ON COLUMN opportunite.tjm_client IS
    'Taux journalier moyen facturé au client.';
COMMENT ON COLUMN opportunite.tjm_preneur IS
    'Taux journalier moyen versé au freelance preneur, renseigné à la clôture.';
COMMENT ON COLUMN opportunite.type_mission IS
    'Run / Build / Expertise... Liste ouverte (non contrainte par un CHECK), contrairement à source, mode, timing et mode_candidature.';
COMMENT ON COLUMN opportunite.mode IS
    'Mode de travail : teletravail, hybride ou presentiel (cf. chk_opp_mode).';
COMMENT ON COLUMN opportunite.timing IS
    'Urgence de la mission : urgent, moins_1_mois ou plus_1_mois (cf. chk_opp_timing).';
COMMENT ON COLUMN opportunite.mode_candidature IS
    'Voie de mise en relation : via_apporteur, contact_direct_recruteur ou via_moteur (cf. chk_opp_mode_candidature). Précision (nom, mail, canal) dans mode_candidature_precision.';
COMMENT ON COLUMN opportunite.nombre_jours IS
    'Nombre de jours effectif de la mission, renseigné à la clôture (distinct de duree_annoncee_mois, issue du template).';
COMMENT ON COLUMN opportunite.niveau_diffusion IS
    'Choisi par l''apporteur : libre (relais public bienvenu), reseau_perso (défaut, recommandation de personne à personne), interne_strict (membres du collectif uniquement).';
COMMENT ON COLUMN opportunite.date_ouverture_exterieur IS
    'Date de publication + délai laissé aux membres (2 jours à ce jour) avant ouverture hors collectif. Informative uniquement, sans objet en niveau_diffusion = interne_strict.';
COMMENT ON COLUMN opportunite.statut IS
    'Un des 7 statuts du cycle de vie. Transitions libres (saut, retour arrière, réouverture) : voir table historique_statut pour la traçabilité datée.';
COMMENT ON COLUMN opportunite.date_signal IS
    'Date de détection de l''opportunité.';
COMMENT ON COLUMN opportunite.date_cloture IS
    'Date de signature ou de perte. Obligatoire dès que statut = signe ou perdu (cf. chk_opp_cloture_obligatoire).';
COMMENT ON COLUMN opportunite.date_relance IS
    'Obligatoire au passage en en_pause (cf. chk_opp_date_relance_obligatoire).';
COMMENT ON COLUMN opportunite.raison_perte IS
    'Motif de la perte, obligatoire au passage en perdu (cf. chk_opp_raison_perte_obligatoire).';

CREATE INDEX idx_opportunite_statut ON opportunite(statut);
CREATE INDEX idx_opportunite_ville ON opportunite(ville);
CREATE INDEX idx_opportunite_mode ON opportunite(mode);
CREATE INDEX idx_opportunite_client_final ON opportunite(client_final_nom);
CREATE INDEX idx_opportunite_date_signal ON opportunite(date_signal);
CREATE INDEX idx_opportunite_date_relance ON opportunite(date_relance) WHERE statut = 'en_pause';
CREATE INDEX idx_opportunite_apporteur ON opportunite(apporteur_id);
CREATE INDEX idx_opportunite_moteur ON opportunite(moteur_id);
CREATE INDEX idx_opportunite_preneur_membre ON opportunite(preneur_membre_id);
CREATE INDEX idx_opportunite_saisi_par ON opportunite(saisi_par_id);

-- -----------------------------------------------------------------------------
-- TABLES DE LIAISON : TECHNOLOGIES, CONTACTS, PROFILS EXTERIEURS
-- -----------------------------------------------------------------------------

CREATE TABLE opportunite_technologie (
    opportunite_id  BIGINT  NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    technologie_id  BIGINT  NOT NULL REFERENCES technologie(id) ON DELETE RESTRICT,
    est_principale  BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (opportunite_id, technologie_id)
);

COMMENT ON TABLE opportunite_technologie IS
    'Technologies demandées par une opportunité. est_principale distingue la technologie principale des technologies bonus (une seule principale par opportunité, cf. uq_opp_tech_une_principale).';

CREATE UNIQUE INDEX uq_opp_tech_une_principale
    ON opportunite_technologie(opportunite_id)
    WHERE est_principale;

CREATE TABLE profil_exterieur_technologie (
    profil_exterieur_id  BIGINT  NOT NULL REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    technologie_id       BIGINT  NOT NULL REFERENCES technologie(id) ON DELETE RESTRICT,

    PRIMARY KEY (profil_exterieur_id, technologie_id)
);

COMMENT ON TABLE profil_exterieur_technologie IS
    'Technologies maîtrisées par un profil contacté hors collectif.';

CREATE TABLE profil_exterieur_opportunite (
    profil_exterieur_id  BIGINT NOT NULL REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    opportunite_id       BIGINT NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,

    PRIMARY KEY (profil_exterieur_id, opportunite_id)
);

COMMENT ON TABLE profil_exterieur_opportunite IS
    'Opportunités pour lesquelles un profil extérieur a été sollicité (un même profil peut être lié à plusieurs opportunités).';

CREATE TABLE opportunite_contact (
    opportunite_id  BIGINT NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    contact_id      BIGINT NOT NULL REFERENCES contact(id) ON DELETE RESTRICT,

    PRIMARY KEY (opportunite_id, contact_id)
);

COMMENT ON TABLE opportunite_contact IS
    'Contacts client rattachés à une opportunité.';

-- -----------------------------------------------------------------------------
-- POSITIONNEMENT
-- -----------------------------------------------------------------------------

CREATE TABLE positionnement (
    id                    BIGSERIAL PRIMARY KEY,
    membre_id             BIGINT NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    opportunite_id        BIGINT NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    date_positionnement   DATE   NOT NULL DEFAULT CURRENT_DATE,
    etat                  VARCHAR(20) NOT NULL DEFAULT 'positionne',
    commentaire           TEXT,

    CONSTRAINT uq_positionnement_membre_opportunite UNIQUE (membre_id, opportunite_id),
    CONSTRAINT chk_positionnement_etat
        CHECK (etat IN ('positionne', 'presente', 'retenu', 'ecarte'))
);

COMMENT ON TABLE positionnement IS
    'Intérêt signalé par un membre sur une opportunité en signal ou matching. Ne réserve rien : plusieurs membres peuvent se positionner sur la même opportunité.';
COMMENT ON COLUMN positionnement.etat IS
    'positionne (candidat) / presente au client / retenu (devient le preneur) / ecarte.';

CREATE INDEX idx_positionnement_opportunite ON positionnement(opportunite_id);

-- -----------------------------------------------------------------------------
-- NOTE
-- -----------------------------------------------------------------------------

CREATE TABLE note (
    id               BIGSERIAL PRIMARY KEY,
    opportunite_id   BIGINT      NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    auteur_id        BIGINT      NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_redaction   TIMESTAMPTZ NOT NULL DEFAULT now(),
    contenu          TEXT        NOT NULL
);

COMMENT ON TABLE note IS
    'Note libre sur une opportunité, écrite par tout membre (positionné ou non) et lisible par tous.';

CREATE INDEX idx_note_opportunite ON note(opportunite_id);

-- -----------------------------------------------------------------------------
-- HISTORIQUE DES STATUTS
-- -----------------------------------------------------------------------------

CREATE TABLE historique_statut (
    id                BIGSERIAL PRIMARY KEY,
    opportunite_id    BIGINT      NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    ancien_statut     VARCHAR(20),
    nouveau_statut    VARCHAR(20) NOT NULL,
    auteur_id         BIGINT      NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_changement   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_hist_ancien_statut
        CHECK (ancien_statut IS NULL OR ancien_statut IN
               ('signal', 'matching', 'propose', 'en_discussion', 'signe', 'perdu', 'en_pause')),
    CONSTRAINT chk_hist_nouveau_statut
        CHECK (nouveau_statut IN
               ('signal', 'matching', 'propose', 'en_discussion', 'signe', 'perdu', 'en_pause'))
);

COMMENT ON TABLE historique_statut IS
    'Historique daté et complet des changements de statut d''une opportunité, avec l''auteur de chaque changement. Alimentée automatiquement par le trigger trg_opportunite_historique_statut, y compris pour les écritures faites hors interface.';
COMMENT ON COLUMN historique_statut.ancien_statut IS
    'NULL pour la toute première ligne (création de l''opportunité au statut signal).';

CREATE INDEX idx_historique_statut_opportunite ON historique_statut(opportunite_id);

-- -----------------------------------------------------------------------------
-- JOURNAL D'ACTIONS
-- -----------------------------------------------------------------------------

CREATE TABLE journal_action (
    id               BIGSERIAL PRIMARY KEY,
    opportunite_id   BIGINT REFERENCES opportunite(id) ON DELETE RESTRICT,
    auteur_id        BIGINT NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_action      TIMESTAMPTZ NOT NULL DEFAULT now(),
    type_action      VARCHAR(40) NOT NULL,
    commentaire      TEXT,

    CONSTRAINT chk_journal_type_action
        CHECK (type_action IN (
            'positionnement',
            'presentation_profil',
            'note',
            'profil_exterieur_contacte',
            'contact_cree_modifie',
            'entreprise_cree_modifiee',
            'changement_statut'
        ))
);

COMMENT ON TABLE journal_action IS
    'Journal de ce que chacun a fait sur une opportunité (qui, quoi, quand). Tout auteur, humain ou agent, écrit sous un compte identifié (ENF-05).';

CREATE INDEX idx_journal_action_opportunite ON journal_action(opportunite_id);
CREATE INDEX idx_journal_action_auteur ON journal_action(auteur_id);

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
        v_auteur_id := current_setting('app.current_membre_id', true)::BIGINT;

        IF v_auteur_id IS NULL THEN
            RAISE EXCEPTION
                'app.current_membre_id doit être défini avant tout changement de statut (SET app.current_membre_id = ...)';
        END IF;

        INSERT INTO historique_statut (opportunite_id, ancien_statut, nouveau_statut, auteur_id)
        VALUES (NEW.id, OLD.statut, NEW.statut, v_auteur_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_opportunite_historique_statut() IS
    'Alimente historique_statut à chaque changement de opportunite.statut. Exige que la session ait défini app.current_membre_id (SET LOCAL app.current_membre_id = ''<id>'').';

CREATE TRIGGER trg_opportunite_historique_statut
    AFTER UPDATE OF statut ON opportunite
    FOR EACH ROW
    EXECUTE FUNCTION fn_opportunite_historique_statut();

CREATE FUNCTION fn_opportunite_historique_statut_creation() RETURNS TRIGGER AS $$
DECLARE
    v_auteur_id BIGINT;
BEGIN
    v_auteur_id := COALESCE(current_setting('app.current_membre_id', true)::BIGINT, NEW.apporteur_id);

    INSERT INTO historique_statut (opportunite_id, ancien_statut, nouveau_statut, auteur_id)
    VALUES (NEW.id, NULL, NEW.statut, v_auteur_id);

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

COMMIT;
