-- =============================================================================
-- KOLONI CRM - Vues
-- Consultants (membres et profils extérieurs), date d'ouverture à l'extérieur,
-- dernière sollicitation d'un profil extérieur.
-- =============================================================================

BEGIN;

-- Dernière fois où on a fait appel à chaque profil (un profil jamais sollicité n'apparaît pas)
CREATE VIEW profil_exterieur_derniere_sollicitation AS
SELECT DISTINCT ON (profil_exterieur_id)
       profil_exterieur_id, opportunite_id, sollicite_par_id, date_sollicitation, issue
FROM profil_exterieur_opportunite
ORDER BY profil_exterieur_id, date_sollicitation DESC, opportunite_id DESC;

COMMENT ON VIEW profil_exterieur_derniere_sollicitation IS
    'Une ligne par profil extérieur déjà sollicité : sa sollicitation la plus récente (date, opportunité, issue).';

-- Consultants : membres et profils extérieurs réunis dans une seule liste, sans fusionner les tables.
-- Un profil extérieur relié à un compte membre (membre_id) n'est repris que par sa ligne de membre.
-- Les identifiants viennent de deux tables : une personne se reconnaît par (origine, id).
CREATE VIEW consultant AS
SELECT 'membre' AS origine, m.id, m.nom, m.prenom, m.ville, m.lien_linkedin,
       m.disponibilite, m.actif
FROM membre m
UNION ALL
SELECT 'exterieur', p.id, p.nom, p.prenom, p.ville, p.lien_linkedin,
       p.disponibilite, TRUE
FROM profil_exterieur p
WHERE p.membre_id IS NULL;

COMMENT ON VIEW consultant IS
    'Tous les consultants en une liste : membres du collectif (origine membre) et profils extérieurs pas encore membres (origine exterieur). La disponibilité d''un membre est un état (inconnu, en_recherche, a_l_ecoute, en_mission) ; celle d''un profil extérieur est un texte libre.';

-- Date à partir de laquelle une opportunité peut s'ouvrir hors du collectif : la date de qualification
-- plus le délai laissé aux membres (2 jours calendaires à ce jour, règle encore en cours de rédaction
-- chez le client). Rien n'est stocké. La date de qualification est lue à l'heure de Paris : sans cela,
-- le jour dépendrait du fuseau de la session. Une opportunité en interne strict ne s'ouvre jamais à
-- l'extérieur, et une opportunité non qualifiée n'a pas encore de date.
CREATE VIEW opportunite_ouverture AS
SELECT id,
       (date_qualification AT TIME ZONE 'Europe/Paris')::date + 2 AS date_ouverture_exterieur
FROM opportunite
WHERE niveau_diffusion <> 'interne_strict' AND date_qualification IS NOT NULL;

COMMENT ON VIEW opportunite_ouverture IS
    'Date d''ouverture à l''extérieur du collectif, calculée : date de qualification + 2 jours calendaires. Absente pour une opportunité en interne_strict ou pas encore qualifiée.';
COMMIT;
