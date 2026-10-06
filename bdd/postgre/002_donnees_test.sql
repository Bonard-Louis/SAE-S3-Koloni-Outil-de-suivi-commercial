-- =============================================================================
-- KOLONI CRM - Données de test (fictives)
-- Jeu de données issu de bdd/data/Contacts_fictifs.csv. Aucune donnée réelle.
-- À exécuter après 001_creation_schema_koloni.sql, sur une base vide.
-- =============================================================================

BEGIN;

-- MEMBRES
INSERT INTO membre (id, nom, prenom, mail, telephone, notes, role, ville, disponibilite, date_fin_mission, actif) VALUES
  (1, 'Exemple', 'Alice', 'alice.exemple@example.com', '0601020301', 'Data analyst freelance', 'administrateur', 'Bordeaux', 'en_recherche', NULL, TRUE),
  (2, 'Fictif', 'Bastien', 'bastien.fictif@example.com', '0601020302', 'Analytics engineer freelance', 'membre', 'Grenoble', 'en_mission', '2026-12-18', TRUE),
  (3, 'Démo', 'Camille', 'camille.demo@example.com', '0601020303', 'Analytics engineer freelance', 'membre', 'Nantes', 'en_recherche', NULL, TRUE),
  (4, 'Test', 'Damien', 'damien.test@example.com', '0601020304', 'Data analyst freelance', 'membre', 'Strasbourg', 'en_mission', '2027-03-31', TRUE),
  (5, 'Factice', 'Élodie', 'elodie.factice@example.com', '0601020305', 'Analytics engineer freelance', 'membre', 'Lyon', 'en_recherche', NULL, TRUE),
  (6, 'Modèle', 'Fabien', 'fabien.modele@example.com', '0601020306', 'Consultant BI freelance (ancien membre du collectif)', 'membre', 'Rennes', 'en_recherche', NULL, FALSE);

-- TECHNOLOGIES
INSERT INTO technologie (id, nom) VALUES
  (1, 'Talend'),
  (2, 'Power BI'),
  (3, 'Python'),
  (4, 'SQL'),
  (5, 'dbt'),
  (6, 'Snowflake'),
  (7, 'Azure Data Factory'),
  (8, 'Tableau'),
  (9, 'Airflow'),
  (10, 'Qlik Sense');

-- ENTREPRISES CLIENTES
INSERT INTO entreprise_cliente (id, nom, secteur, taille, ville) VALUES
  (1, 'Xi Factice Médias', 'Médias', 'ETI', 'Nantes'),
  (2, 'Gamma Exemple Industrie', 'Industrie', 'Grand groupe', 'Rennes'),
  (3, 'Lambda Démo Transport', 'Transport', 'PME', 'Strasbourg'),
  (4, 'Nu Test Immobilier', 'Immobilier', 'ETI', 'Lille'),
  (5, 'Mu Exemple Agroalimentaire', 'Agroalimentaire', 'Grand groupe', 'Nice'),
  (6, 'Omicron Modèle Services', 'Services', 'PME', 'Bordeaux'),
  (7, 'Delta Test Banque', 'Banque', 'ETI', 'Rennes'),
  (8, 'Iota Imaginaire Logistique', 'Logistique', 'Grand groupe', 'Bordeaux'),
  (9, 'Zêta Modèle Retail', 'Commerce de détail', 'PME', 'Tours'),
  (10, 'Alpha Fictive SAS', 'Conseil', 'ETI', 'Grenoble'),
  (11, 'Kappa Fictive Télécom', 'Télécommunications', 'Grand groupe', 'Toulouse');

-- CONTACTS (côté client)
INSERT INTO contact (id, nom, prenom, role, entreprise_cliente_id, mail, telephone) VALUES
  (1, 'Démo', 'Ursule', 'Responsable BI', 1, 'ursule.demo@example.com', NULL),
  (2, 'Test', 'Valentin', 'Responsable achats IT', 2, 'valentin.test@example.com', NULL),
  (3, 'Factice', 'William', 'Responsable achats IT', 2, 'william.factice@example.com', '0610203451'),
  (4, 'Modèle', 'Yasmine', 'Responsable BI', 3, 'yasmine.modele@example.com', NULL),
  (5, 'Specimen', 'Zoé', 'DSI', 4, 'zoe.specimen@example.com', NULL),
  (6, 'Prototype', 'Adrien', 'Directrice data', 5, 'adrien.prototype@example.com', '0610203862'),
  (7, 'Imaginaire', 'Béatrice', 'Responsable BI', 5, 'beatrice.imaginaire@example.com', NULL),
  (8, 'Exemple', 'Cédric', 'DSI', 6, 'cedric.exemple@example.com', NULL),
  (9, 'Fictif', 'Diane', 'Directeur de la transformation', 7, 'diane.fictif@example.com', '0610204273'),
  (10, 'Démo', 'Émile', 'Head of Data', 4, 'emile.demo@example.com', NULL),
  (11, 'Test', 'Florence', 'DSI', 8, 'florence.test@example.com', NULL),
  (12, 'Factice', 'Guillaume', 'DSI', 4, 'guillaume.factice@example.com', '0610204684'),
  (13, 'Modèle', 'Hélène', 'CTO', 9, 'helene.modele@example.com', NULL),
  (14, 'Specimen', 'Isabelle', 'DSI', 6, 'isabelle.specimen@example.com', NULL),
  (15, 'Prototype', 'Jérôme', 'Responsable achats IT', 4, 'jerome.prototype@example.com', '0610205095'),
  (16, 'Imaginaire', 'Laura', 'Responsable BI', 3, 'laura.imaginaire@example.com', NULL),
  (17, 'Exemple', 'Marc', 'Responsable achats IT', 8, 'marc.exemple@example.com', NULL),
  (18, 'Fictif', 'Nathalie', 'Head of Data', 4, 'nathalie.fictif@example.com', '0610205506'),
  (19, 'Démo', 'Olivier', 'DSI', 5, 'olivier.demo@example.com', NULL),
  (20, 'Test', 'Pauline', 'Directrice data', 7, 'pauline.test@example.com', NULL),
  (21, 'Factice', 'Romain', 'Responsable partenariats', 7, 'romain.factice@example.com', '0610205917'),
  (22, 'Modèle', 'Sandrine', 'Fondatrice', 9, 'sandrine.modele@example.com', NULL),
  (23, 'Specimen', 'Théo', 'Directeur associé', 8, 'theo.specimen@example.com', NULL),
  (24, 'Prototype', 'Vanessa', 'Fondatrice', 10, 'vanessa.prototype@example.com', '0610206328'),
  (25, 'Imaginaire', 'Aurélie', 'Directeur associé', 11, 'aurelie.imaginaire@example.com', NULL),
  (26, 'Exemple', 'Bruno', 'Fondatrice', 2, 'bruno.exemple@example.com', NULL),
  (27, 'Fictif', 'Chloé', 'Directeur associé', 3, 'chloe.fictif@example.com', '0610206739'),
  (28, 'Démo', 'Denis', 'Responsable partenariats', 8, 'denis.demo@example.com', NULL),
  (29, 'Imaginaire', 'Béatrice', 'Responsable BI', 5, 'b.imaginaire@example.com', NULL);

-- PROFILS EXTÉRIEURS (freelances contactés hors collectif)
INSERT INTO profil_exterieur (id, nom, prenom, moyen_contact, niveau, experiences_cles, ville, disponibilite, tjm, date_sollicitation, issue, auteur_id) VALUES
  (1, 'Specimen', 'Gaëlle', 'gaelle.specimen@example.com', 'senior', 'Consultant BI depuis 4 ans, missions chez des clients du secteur industrie.', 'Toulouse', 'Disponible à partir du 1er novembre 2026', 590, '2026-09-03', 'retenu', 2),
  (2, 'Prototype', 'Henri', 'henri.prototype@example.com', 'expert', 'Data engineer depuis 5 ans, missions chez des clients du secteur retail.', 'Montpellier', 'Disponible dans 2 mois', 740, '2026-09-05', 'ecarte_client', 3),
  (3, 'Imaginaire', 'Inès', 'ines.imaginaire@example.com', 'operationnel', 'Data engineer depuis 6 ans, missions chez des clients du secteur télécom.', 'Bordeaux', 'En mission jusquen janvier 2027', 480, '2026-09-07', 'indisponible', 4),
  (4, 'Exemple', 'Julien', 'julien.exemple@example.com', 'senior', 'Consultant BI depuis 7 ans, missions chez des clients du secteur banque.', 'Dijon', 'Disponible immédiatement', 580, '2026-09-09', 'sans_reponse_profil', 5),
  (5, 'Fictif', 'Karine', 'karine.fictif@example.com', 'expert', 'Consultant BI depuis 8 ans, missions chez des clients du secteur industrie.', 'Saint-Denis (La Réunion)', 'Disponible à partir du 1er novembre 2026', 730, '2026-09-11', 'sans_retour_client', 1),
  (6, 'Démo', 'Laurent', 'laurent.demo@example.com', 'operationnel', 'Data engineer depuis 9 ans, missions chez des clients du secteur retail.', 'Tours', 'Disponible dans 2 mois', 470, '2026-09-13', NULL, 2),
  (7, 'Test', 'Manon', 'manon.test@example.com', 'senior', 'Data engineer depuis 10 ans, missions chez des clients du secteur télécom.', 'Grenoble', 'En mission jusquen janvier 2027', 610, '2026-09-15', 'presente', 3),
  (8, 'Factice', 'Nicolas', 'nicolas.factice@example.com', 'expert', 'Analytics engineer depuis 11 ans, missions chez des clients du secteur banque.', 'Toulouse', 'Disponible immédiatement', 720, '2026-09-17', 'retenu', 4),
  (9, 'Modèle', 'Océane', 'oceane.modele@example.com', 'operationnel', 'Consultant BI depuis 3 ans, missions chez des clients du secteur industrie.', 'Nice', 'Disponible à partir du 1er novembre 2026', 460, '2026-09-19', 'ecarte_client', 5),
  (10, 'Specimen', 'Pierre', 'pierre.specimen@example.com', 'senior', 'Data analyst depuis 4 ans, missions chez des clients du secteur retail.', 'Lyon', 'Disponible dans 2 mois', 600, '2026-09-21', 'indisponible', 1),
  (11, 'Prototype', 'Quentin', 'quentin.prototype@example.com', 'expert', 'Analytics engineer depuis 5 ans, missions chez des clients du secteur télécom.', 'Dijon', 'En mission jusquen janvier 2027', 750, '2026-09-23', 'sans_reponse_profil', 2),
  (12, 'Imaginaire', 'Rachel', 'rachel.imaginaire@example.com', 'operationnel', 'Data engineer depuis 6 ans, missions chez des clients du secteur banque.', 'Bordeaux', 'Disponible immédiatement', 450, '2026-09-25', 'sans_retour_client', 3),
  (13, 'Exemple', 'Sophie', 'sophie.exemple@example.com', 'senior', 'Data engineer depuis 7 ans, missions chez des clients du secteur industrie.', 'Nantes', 'Disponible à partir du 1er novembre 2026', 590, '2026-09-27', NULL, 4),
  (14, 'Fictif', 'Thomas', 'thomas.fictif@example.com', 'expert', 'Analytics engineer depuis 8 ans, missions chez des clients du secteur retail.', 'Saint-Denis (La Réunion)', 'Disponible dans 2 mois', 740, '2026-09-01', 'presente', 5),
  (15, 'Factice', 'Élodie', 'e.factice@example.com', 'operationnel', 'Analytics engineer depuis 9 ans, missions chez des clients du secteur télécom.', 'Lyon', 'En mission jusquen janvier 2027', 480, '2026-09-03', 'retenu', 1);

INSERT INTO profil_exterieur_technologie (profil_exterieur_id, technologie_id) VALUES
  (1, 2),
  (1, 8),
  (1, 10),
  (2, 3),
  (2, 9),
  (2, 1),
  (3, 3),
  (3, 9),
  (3, 1),
  (4, 2),
  (4, 8),
  (4, 10),
  (5, 2),
  (5, 8),
  (5, 10),
  (6, 3),
  (6, 9),
  (6, 1),
  (7, 3),
  (7, 9),
  (7, 1),
  (8, 5),
  (8, 4),
  (8, 6),
  (9, 2),
  (9, 8),
  (9, 10),
  (10, 4),
  (10, 2),
  (11, 5),
  (11, 4),
  (11, 6),
  (12, 3),
  (12, 9),
  (12, 1),
  (13, 3),
  (13, 9),
  (13, 1),
  (14, 5),
  (14, 4),
  (14, 6),
  (15, 5),
  (15, 4),
  (15, 6);

-- OPPORTUNITÉS
INSERT INTO opportunite (id, titre, source, temperature, type_mission, niveau_recherche, client_final_nom, client_final_secteur, client_final_taille, apporteur_id, moteur_id, preneur_membre_id, preneur_profil_exterieur_id, tjm_annonce, tjm_client, tjm_preneur, duree_annoncee_mois, nombre_jours, ville, mode, timing, mode_candidature, niveau_diffusion, statut, date_signal, date_cloture, date_relance, raison_perte) VALUES
  (1, 'Migration reporting vers Power BI', 'client', 'chaud', 'Build', 'senior', 'Nu Test Immobilier', 'Immobilier', 'ETI', 1, NULL, NULL, NULL, 550, 700, NULL, 6, NULL, 'Lille', 'hybride', 'urgent', 'via_apporteur', 'reseau_perso', 'signal', '2026-10-01', NULL, NULL, NULL),
  (2, 'Industrialisation de pipelines de données', 'commercial', 'chaud', 'Build', 'expert', 'Delta Test Banque', 'Banque', 'ETI', 2, 3, NULL, NULL, 650, 820, NULL, 9, NULL, 'Rennes', 'hybride', 'moins_1_mois', 'via_moteur', 'interne_strict', 'matching', '2026-09-24', NULL, NULL, NULL),
  (3, 'Refonte du datawarehouse Snowflake', 'contact', 'tiede', 'Build', 'senior', 'Omicron Modèle Services', 'Services', 'PME', 3, NULL, NULL, NULL, 600, 760, NULL, 12, NULL, 'Bordeaux', 'teletravail', 'plus_1_mois', 'via_apporteur', 'reseau_perso', 'matching', '2026-09-20', NULL, NULL, NULL),
  (4, 'Tierce maintenance applicative BI', 'client', 'tiede', 'Run', 'operationnel', 'Lambda Démo Transport', 'Transport', 'PME', 4, NULL, NULL, NULL, 420, 540, NULL, 6, NULL, 'Strasbourg', 'presentiel', 'plus_1_mois', 'contact_direct_recruteur', 'libre', 'propose', '2026-09-10', NULL, NULL, NULL),
  (5, 'Mise en place de dbt et de la modélisation analytique', 'commercial', 'chaud', 'Expertise', 'expert', 'Mu Exemple Agroalimentaire', 'Agroalimentaire', 'Grand groupe', 1, 2, NULL, NULL, 700, 880, NULL, 4, NULL, 'Dijon', 'teletravail', 'moins_1_mois', 'via_moteur', 'reseau_perso', 'en_discussion', '2026-09-05', NULL, NULL, NULL),
  (6, 'Tableaux de bord de pilotage logistique', 'client', 'chaud', 'Build', 'senior', 'Iota Imaginaire Logistique', 'Logistique', 'Grand groupe', 5, NULL, 2, NULL, 560, 710, 540, 8, 120, 'Bordeaux', 'hybride', 'urgent', 'via_apporteur', 'reseau_perso', 'signe', '2026-08-12', '2026-09-15', NULL, NULL),
  (7, 'Data engineer pour plateforme retail', 'commercial', 'tiede', 'Build', 'senior', 'Zêta Modèle Retail', 'Commerce de détail', 'PME', 2, 4, NULL, 2, 580, 740, 560, 10, 150, 'Tours', 'hybride', 'plus_1_mois', 'via_moteur', 'libre', 'signe', '2026-08-01', '2026-09-05', NULL, NULL),
  (8, 'Audit de la chaîne d''alimentation BI', 'contact', 'tiede', 'Expertise', 'expert', 'Kappa Fictive Télécom', 'Télécommunications', 'Grand groupe', 3, NULL, NULL, NULL, 720, 900, NULL, 2, NULL, 'Toulouse', 'presentiel', 'plus_1_mois', 'via_apporteur', 'interne_strict', 'perdu', '2026-07-20', '2026-09-02', NULL, 'Budget gelé côté client, projet reporté à l''an prochain.'),
  (9, 'Migration Qlik Sense vers Power BI', 'client', 'tiede', 'Build', 'senior', 'Alpha Fictive SAS', 'Conseil', 'ETI', 1, NULL, NULL, NULL, 550, 690, NULL, 5, NULL, 'Grenoble', 'hybride', 'plus_1_mois', 'contact_direct_recruteur', 'reseau_perso', 'en_pause', '2026-08-20', NULL, '2026-11-15', NULL),
  (10, 'Cadrage d''un projet de data gouvernance', NULL, NULL, 'Expertise', 'senior', 'Gamma Exemple Industrie', 'Industrie', 'Grand groupe', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Montpellier', NULL, NULL, NULL, 'reseau_perso', 'signal', '2026-10-03', NULL, NULL, NULL);

INSERT INTO opportunite_technologie (opportunite_id, technologie_id, est_principale) VALUES
  (1, 2, TRUE),
  (1, 4, FALSE),
  (2, 9, TRUE),
  (2, 3, FALSE),
  (2, 6, FALSE),
  (3, 6, TRUE),
  (3, 5, FALSE),
  (4, 10, TRUE),
  (5, 5, TRUE),
  (5, 4, FALSE),
  (5, 6, FALSE),
  (6, 8, TRUE),
  (6, 4, FALSE),
  (7, 3, TRUE),
  (7, 7, FALSE),
  (8, 1, TRUE),
  (9, 2, TRUE),
  (9, 10, FALSE),
  (10, 4, TRUE);

INSERT INTO opportunite_contact (opportunite_id, contact_id) VALUES
  (1, 5),
  (1, 10),
  (2, 9),
  (2, 20),
  (3, 8),
  (3, 14),
  (4, 4),
  (4, 16),
  (5, 6),
  (5, 7),
  (6, 11),
  (6, 17),
  (7, 13),
  (7, 22),
  (8, 25),
  (9, 24),
  (10, 2),
  (10, 3);

INSERT INTO profil_exterieur_opportunite (profil_exterieur_id, opportunite_id) VALUES
  (1, 2),
  (2, 2),
  (3, 5),
  (7, 2),
  (4, 3),
  (5, 7),
  (8, 6);

-- POSITIONNEMENTS
INSERT INTO positionnement (membre_id, opportunite_id, date_positionnement, etat, commentaire) VALUES
  (1, 1, '2026-10-03', 'positionne', 'Disponible dès novembre, a déjà fait une migration Power BI.'),
  (3, 1, '2026-10-05', 'positionne', NULL),
  (1, 2, '2026-10-03', 'positionne', 'Intéressé par le volet Snowflake.'),
  (2, 2, '2026-10-05', 'positionne', NULL),
  (3, 3, '2026-10-01', 'positionne', NULL),
  (5, 3, '2026-10-04', 'positionne', 'Fin de mission en décembre, disponible à ce moment-là.');

INSERT INTO note (opportunite_id, auteur_id, date_redaction, contenu) VALUES
  (1, 3, '2026-10-01 10:15:00+02', 'Le client souhaite une démo du rapport actuel avant le démarrage.'),
  (2, 5, '2026-10-02 10:20:00+02', 'Le client demande deux profils à présenter avant la fin du mois.'),
  (5, 1, '2026-10-03 10:25:00+02', 'Réunion de cadrage prévue la semaine prochaine.'),
  (8, 3, '2026-10-01 10:30:00+02', 'Projet reporté, à relancer au printemps.'),
  (9, 1, '2026-10-02 10:35:00+02', 'Relance prévue après la clôture budgétaire.');

INSERT INTO journal_action (opportunite_id, auteur_id, date_action, type_action, commentaire) VALUES
  (1, 3, '2026-10-01 11:10:00+02', 'positionnement', 'Positionnement de Camille.'),
  (2, 5, '2026-10-02 11:17:00+02', 'positionnement', 'Positionnement d''Élodie.'),
  (2, 3, '2026-10-03 11:24:00+02', 'profil_exterieur_contacte', 'Profil extérieur sollicité pour la mission.'),
  (5, 1, '2026-10-01 11:31:00+02', 'note', 'Note de cadrage ajoutée.'),
  (6, 1, '2026-10-02 11:38:00+02', 'changement_statut', 'Passage au statut signé.');

-- Liens LinkedIn fictifs, dérivés du prénom et du nom
UPDATE membre SET lien_linkedin = 'https://www.linkedin.com/in/' || lower(translate(prenom || '-' || nom, 'éèêëàâîïôöùûüç', 'eeeeaaiioouuuc'));
UPDATE profil_exterieur SET lien_linkedin = 'https://www.linkedin.com/in/' || lower(translate(prenom || '-' || nom, 'éèêëàâîïôöùûüç', 'eeeeaaiioouuuc'));
UPDATE contact SET lien_linkedin = 'https://www.linkedin.com/in/' || lower(translate(prenom || '-' || nom, 'éèêëàâîïôöùûüç', 'eeeeaaiioouuuc'));

-- Resynchronisation des séquences après insertion d'identifiants explicites
SELECT setval(pg_get_serial_sequence('membre', 'id'), (SELECT max(id) FROM membre));
SELECT setval(pg_get_serial_sequence('technologie', 'id'), (SELECT max(id) FROM technologie));
SELECT setval(pg_get_serial_sequence('entreprise_cliente', 'id'), (SELECT max(id) FROM entreprise_cliente));
SELECT setval(pg_get_serial_sequence('contact', 'id'), (SELECT max(id) FROM contact));
SELECT setval(pg_get_serial_sequence('profil_exterieur', 'id'), (SELECT max(id) FROM profil_exterieur));
SELECT setval(pg_get_serial_sequence('opportunite', 'id'), (SELECT max(id) FROM opportunite));

COMMIT;
