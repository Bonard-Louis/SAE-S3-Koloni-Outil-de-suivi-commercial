# Glossaire du schéma KOLONI

Documentation de `001_creation_schema_koloni.sql`. Le script SQL ne
contient aucun commentaire (ni `COMMENT ON` en base, ni `--` dans le
fichier) : toute l'explication du schéma vit exclusivement ici.

Base cible : PostgreSQL 14+.

Références :
- Recueil de besoins v0.2/v0.3, section 3.3 (données à enregistrer)
- Cahier des charges v0.1, sections 3.1 à 3.6, 4 (ENF-05/08/09/11), 7.1

## Principes structurants du script

- Aucune suppression physique des opportunités, ni de leurs traces
  (EF-09 / ENF-08) : toutes les clés étrangères vers des tables « de
  trace » (`positionnement`, `note`, `historique_statut`,
  `journal_action`) sont déclarées en `ON DELETE RESTRICT`, jamais en
  `CASCADE`.
- Désactivation d'un membre = drapeau `actif`, jamais de suppression de
  ligne (EF-02).
- Contraintes portées par la base (`CHECK`, `NOT NULL`) plutôt que par
  la seule interface, pour rester valables aussi pour les écritures d'un
  agent IA hors interface (ENF-05).
- Schéma volontairement simple : seules les 11 entités du recueil, leurs
  tables de liaison n-n, et les contraintes explicitement demandées par
  le CDC sont modélisées. Pas de table ni de mécanisme technique
  supplémentaire (ex. pas de table de suivi des migrations en base : le
  versionnement (CDC 7.1) repose sur les fichiers `.sql` numérotés du
  dossier `migrations/`, appliqués dans l'ordre).

## Plan du script (dans l'ordre de création)

1. `membre` — profil utilisateur du collectif
2. `technologie` — liste de référence partagée
3. `entreprise_cliente` — sociétés (ESN ou client direct)
4. `contact` — interlocuteur chez le client, lié à une entreprise
5. `profil_exterieur` — profil contacté hors collectif
6. `opportunite` — cœur du modèle, avec ses index de recherche/filtre
7. Tables de liaison n-n : `opportunite_technologie`,
   `profil_exterieur_technologie`, `profil_exterieur_opportunite`,
   `opportunite_contact`
8. `positionnement` — intérêt d'un membre sur une opportunité
9. `note` — fil de notes sur une opportunité
10. `historique_statut` — traçabilité datée des changements de statut
11. `journal_action` — qui a fait quoi, y compris hors interface

---

## membre

Compte utilisateur du collectif Koloni : freelance ou administrateur
(cellule commerce). Un même membre peut être administrateur et, sur ses
propres opportunités, apporteur ou moteur.

| Colonne | Explication |
| --- | --- |
| `role` | `administrateur` (droits étendus sur tout) ou `membre`. Ne préjuge pas des rôles « apporteur »/« moteur », portés par opportunité. |
| `disponibilite` | `en_recherche` ou `en_mission` ; sert de signal de visibilité aux autres membres. |
| `date_fin_mission` | Obligatoire uniquement si `disponibilite = en_mission` (contrainte `chk_membre_date_fin_mission`). |
| `actif` | `FALSE` = compte désactivé. Ne supprime jamais la ligne : les traces (positionnements, notes, journal) restent visibles (EF-02). |
| `ville` | Champ texte unique ; `chk_membre_ville_format` rejette une chaîne vide ou faite uniquement d'espaces, comme validation a minima demandée par le recueil. |

## technologie

Liste de référence des technologies (ex. Talend, Power BI, Python),
réutilisée par `opportunite` et `profil_exterieur`, et servant aux
filtres.

## entreprise_cliente

Société (ESN ou client direct) réutilisable d'une opportunité à l'autre.
Sert notamment au filtre « société du contact ». Distincte du client
final d'une opportunité (cf. `opportunite.client_final_nom`), qui peut
être inconnu et n'est stocké qu'en texte libre.

## contact

Interlocuteur chez le client. Peut être lié à plusieurs opportunités dans
le temps (cf. `opportunite_contact`). Modifiable par tout membre (droits
ouverts par défaut — cf. question 1 du client, section 12 du recueil).

## profil_exterieur

Profil contacté hors collectif, saisi sous forme de fiche technique
structurée par celui qui l'a contacté (généralement le moteur). Entité
distincte du contact client. Pas de CV ni pièce jointe (V0).

| Colonne | Explication |
| --- | --- |
| `issue` | Résultat de la sollicitation. Valeurs non figées : liste attendue du client (question 3, section 12 du recueil) — laissé en texte libre volontairement. |
| `auteur_id` | Membre (humain ou agent IA sous compte identifié) ayant contacté et enregistré le profil. |

## opportunite

Opportunité commerciale, du signal détecté à sa clôture (signature ou
perte). Ne fait jamais l'objet d'une suppression physique, y compris
signée ou perdue (EF-09 / ENF-08). Une opportunité signée reste une
opportunité au statut Signé : pas d'objet Mission distinct.

| Colonne | Explication |
| --- | --- |
| `apporteur_id` | Membre qui amène l'opportunité. |
| `saisi_par_id` | Membre qui a créé la fiche dans l'outil, si différent de l'apporteur. |
| `moteur_id` | Membre qui recherche un profil hors collectif, le cas échéant. |
| `preneur_membre_id` / `preneur_profil_exterieur_id` | Freelance retenu : membre du collectif OU profil extérieur, jamais les deux (`chk_opp_preneur_exclusif`). Renseigné à la clôture. |
| `client_final_nom` | Texte libre, souvent inconnu (besoin passant par une ESN). Ne bloque jamais la publication (EF-04). Distinct de la société du contact (`entreprise_cliente`, liée via `contact`). |
| `niveau_diffusion` | `libre`, `reseau_perso` (par défaut, EF-10) ou `interne_strict`. |
| `date_ouverture_exterieur` | Date de publication + délai laissé aux membres. Champ informatif, sans objet si `interne_strict`. Délai de calcul encore en cours de définition côté client : stocké tel quel, non dérivé automatiquement. |
| `statut` | Un des 7 statuts. Transitions libres (saut, retour arrière, réouverture) : aucune contrainte de séquence en base, seul `historique_statut` journalise les changements. |
| `raison_perte` | Obligatoire dès que `statut = perdu` (`chk_opp_raison_perte_obligatoire`). |
| `date_relance` | Obligatoire dès que `statut = en_pause` (`chk_opp_date_relance_obligatoire`). |

Index posés uniquement sur les critères de filtre listés section 3.1 du
recueil : `statut`, `ville`, `mode`, `client_final_nom`, `date_signal`,
et un index partiel sur `date_relance` pour la vue « en pause à
relancer ». Le filtre par technologie s'appuie sur la table de liaison
`opportunite_technologie`. Le filtre par société du contact s'appuie sur
l'index de `contact.entreprise_cliente_id`.

## opportunite_technologie

Technologies demandées par une opportunité. `est_principale` distingue
la technologie principale des technologies en bonus (au plus une
principale par opportunité, via `uq_opp_tech_une_principale`).

## profil_exterieur_technologie

Technologies maîtrisées par un profil contacté hors collectif.

## profil_exterieur_opportunite

Opportunités concernées par un même profil extérieur.

## opportunite_contact

Contacts rattachés à une opportunité. Un même contact peut être lié à
plusieurs opportunités au fil du temps.

## positionnement

Intérêt signalé par un membre sur une opportunité. Ne réserve rien :
plusieurs membres peuvent être positionnés sur la même opportunité. Le
passage à `presente` relève de l'apporteur ou du moteur ; le membre
`retenu` devient le preneur.

| Colonne | Explication |
| --- | --- |
| `etat` | `positionne` (candidat) / `presente` (au client) / `retenu` / `ecarte`. |

## note

Note libre sur une opportunité. Tout membre peut en écrire une,
positionné ou non ; lisible par tous.

## historique_statut

Liste datée et signée des changements de statut d'une opportunité
(EF-07/EF-08). `ancien_statut` est `NULL` pour l'entrée initiale
(Signal). À alimenter par l'application (ou l'agent IA) à chaque
changement, en même temps que la mise à jour de `opportunite.statut`.

## journal_action

Journal de toute action menée sur une opportunité (ou, pour un ajout de
contact/entreprise sans opportunité identifiée, `opportunite_id` est
`NULL`). Couvre aussi les écritures faites hors interface : tout auteur,
humain ou agent IA, écrit sous un compte identifié (ENF-05).

---

## Ce que ce script ne fait pas (volontairement)

- Pas de table de suivi des migrations en base : la table `migrations`
  aurait été une commodité, pas une exigence du recueil ; le
  versionnement du schéma (CDC 7.1) est assuré par les fichiers `.sql`
  numérotés eux-mêmes.
- Pas de trigger de mise à jour automatique d'un champ « dernière
  modification » sur `opportunite` : non demandé, l'horodatage exigé
  porte spécifiquement sur les changements de statut (`historique_statut`).
- Pas de `COMMENT ON` ni de commentaire `--` dans le SQL : toute la
  documentation est ici, dans ce glossaire, à consulter à côté du
  script.

Point à confirmer avec le client si la conformité stricte à ENF-05
(commentaires en base) est requise malgré ce choix.
