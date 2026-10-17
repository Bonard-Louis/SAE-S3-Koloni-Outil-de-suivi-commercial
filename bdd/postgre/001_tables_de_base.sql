-- =============================================================================
-- KOLONI CRM - Tables de base
-- Membres, références (familles de technologies, technologies, entreprises), contacts
-- et profils extérieurs. Exécuté en premier ; les scripts 002 à 005 complètent le schéma.
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
    lien_linkedin     VARCHAR(255),
    notes             TEXT,
    role              VARCHAR(20)   NOT NULL DEFAULT 'membre',
    ville             VARCHAR(100),
    disponibilite     VARCHAR(20)   NOT NULL DEFAULT 'inconnu',
    date_disponibilite DATE,
    dispo_confirmee_le DATE,
    actif             BOOLEAN       NOT NULL DEFAULT TRUE,
    mot_de_passe_hash VARCHAR(255),
    date_creation     TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT uq_membre_mail UNIQUE (mail),
    CONSTRAINT chk_membre_role
        CHECK (role IN ('administrateur', 'membre')),
    CONSTRAINT chk_membre_disponibilite
        CHECK (disponibilite IN ('inconnu', 'en_recherche', 'a_l_ecoute', 'en_mission')),
    CONSTRAINT chk_membre_date_disponibilite
        CHECK (disponibilite IN ('en_mission', 'a_l_ecoute') OR date_disponibilite IS NULL),
    CONSTRAINT chk_membre_linkedin
        CHECK (lien_linkedin IS NULL OR lien_linkedin LIKE 'https://%linkedin.com/%'),
    CONSTRAINT chk_membre_ville_format
        CHECK (ville IS NULL OR length(btrim(ville)) > 0)
);

-- La connexion compare les mails sans tenir compte de la casse : l'unicité doit faire de même
CREATE UNIQUE INDEX uq_membre_mail_minuscule ON membre (lower(mail));

COMMENT ON TABLE membre IS
    'Freelance du collectif Koloni, avec un compte personnel. Un membre désactivé garde toutes ses traces (positionnements, notes, actions).';
COMMENT ON COLUMN membre.lien_linkedin IS
    'URL du profil LinkedIn (optionnel).';
COMMENT ON COLUMN membre.role IS
    'Droits d''action : administrateur ou membre. Un administrateur reste un freelance et peut être apporteur/moteur.';
COMMENT ON COLUMN membre.disponibilite IS
    'inconnu (rien déclaré, valeur d''un compte neuf), en_recherche, a_l_ecoute (en mission mais ouvert à une proposition) ou en_mission. Permet au membre de rendre visible sa disponibilité auprès de tout le collectif.';
COMMENT ON COLUMN membre.date_disponibilite IS
    'Date de fin de mission (en_mission) ou date à partir de laquelle le membre est disponible (a_l_ecoute). Renseignée uniquement pour ces deux états (cf. chk_membre_date_disponibilite).';
COMMENT ON COLUMN membre.dispo_confirmee_le IS
    'Date de la dernière déclaration de disponibilité par le membre, enregistrée par l''application. NULL = jamais déclarée.';
COMMENT ON COLUMN membre.actif IS
    'FALSE = compte désactivé (ex-membre du collectif). Ne jamais supprimer la ligne : conserve l''historique de ses actions.';
COMMENT ON COLUMN membre.mot_de_passe_hash IS
    'Mot de passe haché (scrypt, format PHC), jamais en clair. NULL = connexion impossible.';

-- -----------------------------------------------------------------------------
-- FAMILLE DE TECHNOLOGIES
-- -----------------------------------------------------------------------------

CREATE TABLE famille_technologie (
    id    BIGSERIAL PRIMARY KEY,
    nom   VARCHAR(50) NOT NULL,

    -- Pas de nom vide, ni d'espace au début ou à la fin
    CONSTRAINT chk_famille_technologie_nom
        CHECK (btrim(nom) <> '' AND nom = btrim(nom))
);

-- Unique quelle que soit la casse et les espaces autour : « BI » et « bi » sont la même famille
CREATE UNIQUE INDEX uq_famille_technologie_nom_minuscule ON famille_technologie (lower(btrim(nom)));

COMMENT ON TABLE famille_technologie IS
    'Famille de technologies (ETL, BI, Data warehouse…) : c''est le « domaine » du filtre des opportunités. Liste de référence partagée par les technologies.';

-- -----------------------------------------------------------------------------
-- TECHNOLOGIE
-- -----------------------------------------------------------------------------

CREATE TABLE technologie (
    id          BIGSERIAL PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL,
    famille_id  BIGINT REFERENCES famille_technologie(id) ON DELETE RESTRICT
);

-- Unique quelle que soit la casse et les espaces autour : « Python », « python » et « Python  » sont la même technologie
CREATE UNIQUE INDEX uq_technologie_nom_minuscule ON technologie (lower(btrim(nom)));

CREATE INDEX idx_technologie_famille ON technologie(famille_id);

COMMENT ON TABLE technologie IS
    'Liste de valeurs réutilisable (ex. Talend, Power BI, Python), utilisée par les opportunités et les profils extérieurs, et servant de filtre.';
COMMENT ON COLUMN technologie.famille_id IS
    'Famille de la technologie (cf. famille_technologie), utilisée pour filtrer les opportunités par domaine. Une seule famille par technologie. Facultative.';

-- -----------------------------------------------------------------------------
-- ENTREPRISE CLIENTE
-- -----------------------------------------------------------------------------

CREATE TABLE entreprise_cliente (
    id             BIGSERIAL PRIMARY KEY,
    nom            VARCHAR(255) NOT NULL,
    secteur        VARCHAR(150),
    taille         VARCHAR(50),
    ville          VARCHAR(100),
    date_creation  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Unique quelle que soit la casse et les espaces autour : « Capgemini », « capgemini » et « Capgemini  » sont la même société
CREATE UNIQUE INDEX uq_entreprise_cliente_nom_minuscule ON entreprise_cliente (lower(btrim(nom)));

COMMENT ON TABLE entreprise_cliente IS
    'Société (ESN ou client direct) à laquelle sont rattachés les contacts. Réutilisable d''une opportunité à l''autre, sert au filtre "société du contact".';
COMMENT ON COLUMN entreprise_cliente.nom IS
    'Unique quelle que soit la casse et les espaces autour : évite la création de doublons lors de la saisie répétée d''une même société par différents membres.';

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
    lien_linkedin          VARCHAR(255),
    date_creation          TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_contact_moyen_contact
        CHECK (mail IS NOT NULL OR telephone IS NOT NULL OR lien_linkedin IS NOT NULL),
    CONSTRAINT chk_contact_linkedin
        CHECK (lien_linkedin IS NULL OR lien_linkedin LIKE 'https://%linkedin.com/%')
);

COMMENT ON TABLE contact IS
    'Personne côté client (commercial, DSI, responsable data...), rattachée à une entreprise cliente. Distinct des profils extérieurs (freelances hors collectif). Un même contact peut être lié à plusieurs opportunités au fil du temps.';
COMMENT ON COLUMN contact.role IS
    'Fonction chez le client (ex. commercial, responsable data, DSI).';
COMMENT ON COLUMN contact.mail IS
    'Au moins un moyen de contact (mail, téléphone ou LinkedIn) est requis, cf. chk_contact_moyen_contact.';
COMMENT ON COLUMN contact.telephone IS
    'Au moins un moyen de contact (mail, téléphone ou LinkedIn) est requis, cf. chk_contact_moyen_contact.';
COMMENT ON COLUMN contact.lien_linkedin IS
    'URL du profil LinkedIn. Compte comme moyen de contact, cf. chk_contact_moyen_contact.';
COMMENT ON COLUMN contact.entreprise_cliente_id IS
    'Nullable : le contact peut être saisi avant que son entreprise soit connue. À renseigner dès que possible, recommandé mais non bloquant.';

CREATE INDEX idx_contact_entreprise ON contact(entreprise_cliente_id);

-- Un même profil LinkedIn ne peut pas désigner deux contacts, quelle que soit la casse du lien.
-- Plusieurs contacts sans lien LinkedIn restent possibles.
CREATE UNIQUE INDEX uq_contact_linkedin_minuscule ON contact (lower(lien_linkedin)) WHERE lien_linkedin IS NOT NULL;

-- -----------------------------------------------------------------------------
-- PROFIL EXTERIEUR (contacté hors collectif)
-- -----------------------------------------------------------------------------

CREATE TABLE profil_exterieur (
    id                  BIGSERIAL PRIMARY KEY,
    nom                 VARCHAR(100)  NOT NULL,
    prenom              VARCHAR(100)  NOT NULL,
    moyen_contact       VARCHAR(255)  NOT NULL,
    lien_linkedin       VARCHAR(255),
    niveau              VARCHAR(20),
    experiences_cles    TEXT,
    ville               VARCHAR(100),
    disponibilite       VARCHAR(100),
    tjm                 NUMERIC(8,2),
    auteur_id           BIGINT        NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    membre_id           BIGINT        UNIQUE REFERENCES membre(id) ON DELETE RESTRICT,
    date_creation       TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_profil_ext_linkedin
        CHECK (lien_linkedin IS NULL OR lien_linkedin LIKE 'https://%linkedin.com/%'),
    CONSTRAINT chk_profil_ext_niveau
        CHECK (niveau IS NULL OR niveau IN ('operationnel', 'senior', 'expert'))
);

COMMENT ON TABLE profil_exterieur IS
    'Fiche technique d''un profil freelance contacté hors collectif par un moteur. Peut être lié à plusieurs opportunités. Pas de suppression, pas de pièce jointe/CV dans cette version.';
COMMENT ON COLUMN profil_exterieur.moyen_contact IS
    'Mail, téléphone ou autre canal. Obligatoire : un profil non recontactable n''a pas d''intérêt pour la base de profils qualifiés (cf. UC13).';
COMMENT ON COLUMN profil_exterieur.lien_linkedin IS
    'URL du profil LinkedIn (optionnel).';
COMMENT ON COLUMN profil_exterieur.niveau IS
    'operationnel, senior ou expert, ou NULL si non renseigné (cf. chk_profil_ext_niveau).';
COMMENT ON COLUMN profil_exterieur.ville IS
    'Localisation du profil.';
COMMENT ON COLUMN profil_exterieur.disponibilite IS
    'Texte libre : disponible immédiatement, à partir d''une date...';
COMMENT ON COLUMN profil_exterieur.tjm IS
    'Taux journalier moyen souhaité par le profil.';
COMMENT ON COLUMN profil_exterieur.membre_id IS
    'Compte membre de cette personne, renseigné le jour où le profil extérieur adhère au collectif. NULL tant qu''il n''est pas membre. Un membre ne correspond qu''à un seul profil extérieur. Relié, le profil n''apparaît plus qu''une fois dans la vue consultant.';
COMMENT ON COLUMN profil_exterieur.auteur_id IS
    'Membre qui a saisi la fiche de ce profil (moteur, administrateur ou non). La date et l''issue d''une sollicitation se trouvent dans profil_exterieur_opportunite, une ligne par opportunité.';

COMMIT;
