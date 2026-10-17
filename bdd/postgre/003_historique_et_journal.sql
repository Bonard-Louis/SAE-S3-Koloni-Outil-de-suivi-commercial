-- =============================================================================
-- KOLONI CRM - Historique des statuts et journal d'actions
-- Traçabilité : changements de statut d'une opportunité, et journal de ce que chacun a fait.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- HISTORIQUE DES STATUTS
-- -----------------------------------------------------------------------------

CREATE TABLE historique_statut (
    id                BIGSERIAL PRIMARY KEY,
    opportunite_id    BIGINT      NOT NULL REFERENCES opportunite(id) ON DELETE RESTRICT,
    ancien_statut     VARCHAR(20),
    nouveau_statut    VARCHAR(20) NOT NULL,
    motif             TEXT,
    date_relance      DATE,
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
COMMENT ON COLUMN historique_statut.motif IS
    'Raison de la perte saisie à ce changement, uniquement pour un passage en perdu. Copiée par le trigger : rouvrir puis reperdre une opportunité écrase opportunite.raison_perte, mais chaque motif reste ici.';
COMMENT ON COLUMN historique_statut.date_relance IS
    'Date de relance saisie à ce changement, uniquement pour un passage en en_pause. Copiée par le trigger : chaque pause garde sa propre date.';

CREATE INDEX idx_historique_statut_opportunite ON historique_statut(opportunite_id);

-- -----------------------------------------------------------------------------
-- JOURNAL D'ACTIONS
-- -----------------------------------------------------------------------------

CREATE TABLE journal_action (
    id                     BIGSERIAL PRIMARY KEY,
    opportunite_id         BIGINT REFERENCES opportunite(id) ON DELETE RESTRICT,
    contact_id             BIGINT REFERENCES contact(id) ON DELETE RESTRICT,
    entreprise_cliente_id  BIGINT REFERENCES entreprise_cliente(id) ON DELETE RESTRICT,
    profil_exterieur_id    BIGINT REFERENCES profil_exterieur(id) ON DELETE RESTRICT,
    auteur_id              BIGINT NOT NULL REFERENCES membre(id) ON DELETE RESTRICT,
    date_action            TIMESTAMPTZ NOT NULL DEFAULT now(),
    type_action            VARCHAR(40) NOT NULL,
    commentaire            TEXT,

    -- Les changements de statut ne sont pas ici : ils sont dans historique_statut, qui les journalise déjà
    CONSTRAINT chk_journal_type_action
        CHECK (type_action IN (
            'positionnement',
            'presentation_profil',
            'note',
            'profil_exterieur_contacte',
            'profil_exterieur_modifie',
            'contact_cree_modifie',
            'entreprise_cree_modifiee'
        )),
    -- Chaque type d'action dit sur quel objet elle porte
    CONSTRAINT chk_journal_cible CHECK (
            (type_action <> 'contact_cree_modifie'     OR contact_id IS NOT NULL)
        AND (type_action <> 'entreprise_cree_modifiee' OR entreprise_cliente_id IS NOT NULL)
        AND (type_action NOT IN ('profil_exterieur_contacte', 'profil_exterieur_modifie')
             OR profil_exterieur_id IS NOT NULL)
        AND (type_action NOT IN ('positionnement', 'presentation_profil', 'note')
             OR opportunite_id IS NOT NULL)
    )
);

COMMENT ON TABLE journal_action IS
    'Journal de ce que chacun a fait : qui, quoi, quand, et sur quel objet (opportunité, contact, entreprise cliente ou profil extérieur). Les changements de statut sont dans historique_statut, pas ici. Tout auteur, humain ou agent, écrit sous un compte identifié (ENF-05).';
COMMENT ON COLUMN journal_action.opportunite_id IS
    'Opportunité concernée. Obligatoire pour un positionnement, une présentation de profil et une note ; facultative pour les actions sur un contact, une entreprise ou un profil extérieur, qui peuvent ne se rapporter à aucune opportunité (cf. chk_journal_cible).';
COMMENT ON COLUMN journal_action.contact_id IS
    'Contact touché, obligatoire pour contact_cree_modifie.';
COMMENT ON COLUMN journal_action.entreprise_cliente_id IS
    'Entreprise cliente touchée, obligatoire pour entreprise_cree_modifiee.';
COMMENT ON COLUMN journal_action.profil_exterieur_id IS
    'Profil extérieur touché, obligatoire pour profil_exterieur_contacte et profil_exterieur_modifie.';

CREATE INDEX idx_journal_action_opportunite ON journal_action(opportunite_id);
CREATE INDEX idx_journal_action_contact ON journal_action(contact_id);
CREATE INDEX idx_journal_action_entreprise ON journal_action(entreprise_cliente_id);
CREATE INDEX idx_journal_action_profil_exterieur ON journal_action(profil_exterieur_id);
CREATE INDEX idx_journal_action_auteur ON journal_action(auteur_id);

COMMIT;
