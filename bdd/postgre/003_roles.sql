-- =============================================================================
-- KOLONI CRM - Rôle de l'application
-- Exécuté après 001 (schéma) et 002 (données de test), avec le compte
-- propriétaire des tables (POSTGRES_USER).
--
-- L'application se connecte avec un rôle qui ne possède pas les tables et qui 
-- n'a que les droits dont elle a besoin. 
-- ON DELETE RESTRICT ne protège qu'une ligne vers laquelle pointe une
-- autre table ; seuls les droits empêchent de supprimer une note, un
-- positionnement ou une ligne d'historique.
-- =============================================================================

-- Le mot de passe vient de l'environnement du conteneur (KOLONI_APP_PASSWORD) :
-- il ne figure jamais dans le dépôt.
\getenv mot_de_passe_application KOLONI_APP_PASSWORD

CREATE ROLE koloni_app LOGIN PASSWORD :'mot_de_passe_application';

GRANT USAGE ON SCHEMA public TO koloni_app;

-- Lire, ajouter et modifier. Aucun DELETE, aucun TRUNCATE, aucun droit sur la structure.
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO koloni_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO koloni_app;

-- Historique et journal : ajout seul, jamais de modification.
REVOKE UPDATE ON historique_statut, journal_action FROM koloni_app;

-- Seule exception à l'absence de suppression : corriger un rattachement
-- (technologie ou contact ajouté par erreur sur une opportunité).
GRANT DELETE ON opportunite_technologie, opportunite_contact TO koloni_app;
