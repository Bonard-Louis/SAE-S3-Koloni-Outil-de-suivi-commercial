-- =============================================================================
-- KOLONI CRM - Opportunités
-- Opportunité, tables de liaison (technologies, contacts, profils extérieurs),
-- positionnements et notes.
-- =============================================================================

BEGIN;

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
    client_final_id               BIGINT        REFERENCES entreprise_cliente(id) ON DELETE RESTRICT,
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
    lien_annonce_exterieure       VARCHAR(500),
    statut                        VARCHAR(20)   NOT NULL DEFAULT 'signal',
    date_signal                   DATE          NOT NULL DEFAULT CURRENT_DATE,
    date_cloture                  DATE,
    date_relance                  DATE,
    raison_perte                  TEXT,
    qualifiee_par_id              BIGINT        REFERENCES membre(id) ON DELETE RESTRICT,
    date_qualification            TIMESTAMPTZ,
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
    CONSTRAINT chk_opp_lien_annonce
        CHECK (lien_annonce_exterieure IS NULL OR lien_annonce_exterieure LIKE 'https://%'),
    -- Le secteur et la taille ne servent que si l'entreprise n'est pas connue : sinon ils viennent de l'entreprise liée
    CONSTRAINT chk_opp_client_final_inconnu
        CHECK (client_final_id IS NULL OR (client_final_secteur IS NULL AND client_final_taille IS NULL)),
    CONSTRAINT chk_opp_statut
        CHECK (statut IN ('signal', 'matching', 'propose', 'en_discussion',
                           'signe', 'perdu', 'en_pause')),
    CONSTRAINT chk_opp_raison_perte_obligatoire
        CHECK (statut <> 'perdu' OR btrim(coalesce(raison_perte, '')) <> ''),
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
        CHECK (nombre_jours IS NULL OR nombre_jours >= 0),
    CONSTRAINT chk_opp_qualification_complete
        CHECK ((qualifiee_par_id IS NULL) = (date_qualification IS NULL)),
    CONSTRAINT chk_opp_qualifiee
        CHECK (statut IN ('signal', 'perdu', 'en_pause') OR qualifiee_par_id IS NOT NULL)
);

COMMENT ON TABLE opportunite IS
    'Opportunité commerciale : publiée même incomplète (statut signal), suit un cycle de vie en 7 statuts jusqu''à signature ou perte. Jamais supprimée physiquement.';
COMMENT ON COLUMN opportunite.source IS
    'Qui porte le besoin côté client : client, commercial (ESN) ou contact.';
COMMENT ON COLUMN opportunite.temperature IS
    'Niveau de maturité de l''opportunité : chaud, tiede, ou NULL si non renseigné (cf. chk_opp_temperature). Facultatif, non requis pour la qualification Signal → Matching.';
COMMENT ON COLUMN opportunite.client_final_secteur IS
    'Secteur d''activité du client final, uniquement quand son entreprise n''est pas connue (client_final_id vide). Sinon le secteur est celui de l''entreprise liée (cf. chk_opp_client_final_inconnu).';
COMMENT ON COLUMN opportunite.client_final_taille IS
    'Taille du client final, uniquement quand son entreprise n''est pas connue (client_final_id vide). Sinon la taille est celle de l''entreprise liée (cf. chk_opp_client_final_inconnu).';
COMMENT ON COLUMN opportunite.client_final_id IS
    'Entreprise où se déroule la mission, choisie parmi les entreprises clientes (cf. entreprise_cliente), si elle est connue. Facultatif (souvent inconnue si le besoin passe par une ESN) : ne bloque jamais la publication. Distinct de la société du contact (cf. table contact).';
COMMENT ON COLUMN opportunite.apporteur_id IS
    'Membre qui amène l''opportunité. La relation client passe par lui, le moteur ou directement le candidat, selon mode_candidature.';
COMMENT ON COLUMN opportunite.saisi_par_id IS
    'Membre qui a créé la fiche, uniquement renseigné quand il diffère de l''apporteur.';
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
COMMENT ON COLUMN opportunite.lien_annonce_exterieure IS
    'Lien du post qui ouvre l''opportunité à l''extérieur du collectif, renseigné quand elle est relayée. Facultatif ; doit commencer par https:// (cf. chk_opp_lien_annonce).';
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
COMMENT ON COLUMN opportunite.qualifiee_par_id IS
    'Membre (apporteur ou administrateur) qui a validé explicitement la qualification Signal → Matching. NULL tant que l''opportunité n''est pas qualifiée ; obligatoire au-delà de Signal, sauf perdu et en_pause qui restent possibles avant qualification (cf. chk_opp_qualifiee).';
COMMENT ON COLUMN opportunite.date_qualification IS
    'Date et heure de la validation de la qualification. Renseignée dans le même UPDATE que qualifiee_par_id (cf. chk_opp_qualification_complete).';

CREATE INDEX idx_opportunite_statut ON opportunite(statut);
CREATE INDEX idx_opportunite_ville ON opportunite(ville);
CREATE INDEX idx_opportunite_mode ON opportunite(mode);
CREATE INDEX idx_opportunite_client_final ON opportunite(client_final_id);
CREATE INDEX idx_opportunite_date_signal ON opportunite(date_signal);
CREATE INDEX idx_opportunite_date_relance ON opportunite(date_relance) WHERE statut = 'en_pause';
CREATE INDEX idx_opportunite_apporteur ON opportunite(apporteur_id);
CREATE INDEX idx_opportunite_moteur ON opportunite(moteur_id);
CREATE INDEX idx_opportunite_preneur_membre ON opportunite(preneur_membre_id);
CREATE INDEX idx_opportunite_saisi_par ON opportunite(saisi_par_id);
CREATE INDEX idx_opportunite_qualifiee_par ON opportunite(qualifiee_par_id);

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
    profil_exterieur_id  BIGINT      NOT NULL REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    opportunite_id       BIGINT      NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    sollicite_par_id     BIGINT      NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_sollicitation   DATE        NOT NULL DEFAULT CURRENT_DATE,
    issue                VARCHAR(30),

    PRIMARY KEY (profil_exterieur_id, opportunite_id),
    CONSTRAINT chk_pext_opp_issue
        CHECK (issue IS NULL OR issue IN (
            'presente', 'retenu', 'ecarte_client', 'indisponible',
            'sans_reponse_profil', 'sans_retour_client'
        ))
);

COMMENT ON TABLE profil_exterieur_opportunite IS
    'Sollicitation d''un profil extérieur pour une opportunité : qui l''a sollicité, quand, et avec quelle issue. Un même profil peut être sollicité sur plusieurs opportunités, chacune avec sa propre issue.';
COMMENT ON COLUMN profil_exterieur_opportunite.sollicite_par_id IS
    'Membre qui a sollicité le profil pour cette opportunité (le moteur en général).';
COMMENT ON COLUMN profil_exterieur_opportunite.date_sollicitation IS
    'Date du contact avec le profil pour cette opportunité.';
COMMENT ON COLUMN profil_exterieur_opportunite.issue IS
    'Résultat de cette sollicitation (cf. chk_pext_opp_issue), NULL tant qu''elle est en cours.';

-- Un preneur extérieur doit avoir été sollicité sur cette opportunité.
-- DEFERRABLE : la sollicitation exige l'opportunité et l'opportunité exigerait la sollicitation ;
-- le contrôle est reporté à la fin de la transaction, sinon aucun ordre d'insertion ne passe.
-- Sans effet quand l'opportunité n'a pas de preneur extérieur (colonne NULL).
ALTER TABLE opportunite ADD CONSTRAINT fk_opp_preneur_sollicite
    FOREIGN KEY (preneur_profil_exterieur_id, id)
    REFERENCES profil_exterieur_opportunite (profil_exterieur_id, opportunite_id)
    DEFERRABLE INITIALLY DEFERRED;

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
        CHECK (etat IN ('positionne', 'presente', 'retenu', 'ecarte', 'retire'))
);

COMMENT ON TABLE positionnement IS
    'Intérêt signalé par un membre sur une opportunité en signal ou matching. Ne réserve rien : plusieurs membres peuvent se positionner sur la même opportunité. Jamais supprimé : un membre qui se désiste passe à l''état retire.';
COMMENT ON COLUMN positionnement.etat IS
    'positionne (candidat) / presente au client / retenu (devient le preneur) / ecarte / retire (le membre s''est désisté, la ligne est conservée).';

CREATE INDEX idx_positionnement_opportunite ON positionnement(opportunite_id);

-- Un seul membre est retenu par opportunité : le retenu devient le preneur.
-- Changer de retenu se fait en deux instructions (écarter l'ancien, puis retenir le nouveau).
CREATE UNIQUE INDEX uq_positionnement_un_retenu ON positionnement (opportunite_id) WHERE etat = 'retenu';

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

COMMIT;
