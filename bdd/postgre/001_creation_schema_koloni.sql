BEGIN;

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

CREATE TABLE technologie (
    id    SERIAL PRIMARY KEY,
    nom   VARCHAR(100) NOT NULL,

    CONSTRAINT uq_technologie_nom UNIQUE (nom)
);

CREATE TABLE entreprise_cliente (
    id             BIGSERIAL PRIMARY KEY,
    nom            VARCHAR(255) NOT NULL,
    secteur        VARCHAR(150),
    taille         VARCHAR(50),
    ville          VARCHAR(100),
    date_creation  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE contact (
    id                     BIGSERIAL PRIMARY KEY,
    nom                    VARCHAR(100)  NOT NULL,
    prenom                 VARCHAR(100)  NOT NULL,
    role                   VARCHAR(150),
    entreprise_cliente_id  BIGINT REFERENCES entreprise_cliente(id) ON DELETE RESTRICT,
    mail                   VARCHAR(255),
    telephone              VARCHAR(30),
    date_creation          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_contact_entreprise ON contact(entreprise_cliente_id);

CREATE TABLE profil_exterieur (
    id                  BIGSERIAL PRIMARY KEY,
    nom                 VARCHAR(100)  NOT NULL,
    prenom              VARCHAR(100)  NOT NULL,
    moyen_contact       VARCHAR(255),
    niveau              VARCHAR(20),
    experiences_cles    TEXT,
    ville               VARCHAR(100),
    disponibilite       VARCHAR(100),
    tjm                 NUMERIC(8,2),
    date_sollicitation  DATE          NOT NULL DEFAULT CURRENT_DATE,
    issue               VARCHAR(50),
    auteur_id           BIGINT        NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_creation       TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_profil_ext_niveau
        CHECK (niveau IS NULL OR niveau IN ('operationnel', 'senior', 'expert'))
);

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
    apporteur_id                  BIGINT NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    saisi_par_id                  BIGINT REFERENCES membre(id) ON DELETE RESTRICT,
    moteur_id                     BIGINT REFERENCES membre(id) ON DELETE RESTRICT,
    preneur_membre_id             BIGINT REFERENCES membre(id) ON DELETE RESTRICT,
    preneur_profil_exterieur_id   BIGINT REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    tjm_annonce                   NUMERIC(8,2),
    tjm_client                    NUMERIC(8,2),
    tjm_preneur                   NUMERIC(8,2),
    duree_annoncee_mois           NUMERIC(5,1),
    nombre_jours                  INTEGER,
    charge                        VARCHAR(50),
    ville                         VARCHAR(100),
    mode                          VARCHAR(20),
    timing                        VARCHAR(20),
    mode_candidature               VARCHAR(30),
    mode_candidature_precision     VARCHAR(255),
    niveau_diffusion               VARCHAR(20)  NOT NULL DEFAULT 'reseau_perso',
    date_ouverture_exterieur       DATE,
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
    CONSTRAINT chk_opp_preneur_exclusif
        CHECK (NOT (preneur_membre_id IS NOT NULL AND preneur_profil_exterieur_id IS NOT NULL)),
    CONSTRAINT chk_opp_nombre_jours_positif
        CHECK (nombre_jours IS NULL OR nombre_jours >= 0)
);

CREATE INDEX idx_opportunite_statut ON opportunite(statut);
CREATE INDEX idx_opportunite_ville ON opportunite(ville);
CREATE INDEX idx_opportunite_mode ON opportunite(mode);
CREATE INDEX idx_opportunite_client_final ON opportunite(client_final_nom);
CREATE INDEX idx_opportunite_date_signal ON opportunite(date_signal);
CREATE INDEX idx_opportunite_date_relance ON opportunite(date_relance) WHERE statut = 'en_pause';

CREATE TABLE opportunite_technologie (
    opportunite_id  BIGINT  NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    technologie_id  INTEGER NOT NULL REFERENCES technologie(id) ON DELETE RESTRICT,
    est_principale  BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (opportunite_id, technologie_id)
);

CREATE UNIQUE INDEX uq_opp_tech_une_principale
    ON opportunite_technologie(opportunite_id)
    WHERE est_principale;

CREATE TABLE profil_exterieur_technologie (
    profil_exterieur_id  BIGINT  NOT NULL REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    technologie_id       INTEGER NOT NULL REFERENCES technologie(id) ON DELETE RESTRICT,

    PRIMARY KEY (profil_exterieur_id, technologie_id)
);

CREATE TABLE profil_exterieur_opportunite (
    profil_exterieur_id  BIGINT NOT NULL REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    opportunite_id       BIGINT NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,

    PRIMARY KEY (profil_exterieur_id, opportunite_id)
);

CREATE TABLE opportunite_contact (
    opportunite_id  BIGINT NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    contact_id      BIGINT NOT NULL REFERENCES contact(id) ON DELETE RESTRICT,

    PRIMARY KEY (opportunite_id, contact_id)
);

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

CREATE INDEX idx_positionnement_opportunite ON positionnement(opportunite_id);

CREATE TABLE note (
    id               BIGSERIAL PRIMARY KEY,
    opportunite_id   BIGINT      NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    auteur_id        BIGINT      NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_redaction   TIMESTAMPTZ NOT NULL DEFAULT now(),
    contenu          TEXT        NOT NULL
);

CREATE INDEX idx_note_opportunite ON note(opportunite_id);

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

CREATE INDEX idx_historique_statut_opportunite ON historique_statut(opportunite_id);

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

CREATE INDEX idx_journal_action_opportunite ON journal_action(opportunite_id);
CREATE INDEX idx_journal_action_auteur ON journal_action(auteur_id);

COMMIT;