# Recueil de Besoins

## _Gestion de la Relation Client_

**Projet KOLONI — CRM interne**
Version 0.1 — Document de travail

---

## 1. Contexte

### 1.1 Présentation de l'organisation

Le projet est réalisé pour **KOLONI**, un collectif de freelances indépendants dans la data. Le collectif met en relation des clients ayant des besoins de missions (run, build, expertise) avec des freelances membres du réseau, via un système d'opportunités commerciales apportées et prises en charge par différents membres.

### 1.2 Rôle dans le projet

- Conception technique de la solution
- Développement complet de la solution
- Gestion de la relation client (compréhension des besoins, validation des fonctionnalités)
- Rédaction de la documentation
- Coordination et planification pour respecter les délais

### 1.3 Utilisateurs finaux

Deux profils d'utilisateurs sont identifiés à ce stade :

- **Administrateurs** (4-5 personnes) : membres de la « cellule commerce » de Koloni, chargés de trouver et suivre les opportunités commerciales.
- **Membres** (une cinquantaine) : freelances du collectif, susceptibles de se positionner sur les opportunités et d'être affectés à des missions.

Le partage exact des droits entre ces deux profils reste à affiner avec Grégory et Anaël (cf. section 6). L'outil doit par ailleurs pouvoir être ouvert à d'autres membres du collectif dans un second temps.

### 1.4 Origine et problématique

Aujourd'hui, la gestion des opportunités commerciales chez Koloni repose sur trois outils dont deux informels :

- Un réseau social interne (Circle), où les offres clients sont publiées sous forme de posts ;
- Une table POSTGRESQL personnel tenu par le client, avec des colonnes telles que : titre, client, apporteur, moteur, preneur, TJM client, TJM preneur, nombre de jours, montant facturé, type de deal, statut, date du signal, date de clôture, raison de la perte, notes.
- Un tableur (Google Sheet) commun où l'on retrouve les compétences de chacun des freelances (pas tous renseigné) noter de 1 à 4.

Cette organisation repose presque entièrement sur une seule personne (le client), qui centralise le suivi commercial. Elle ne permet ni de structurer les opportunités et leur cycle de vie, ni de conserver un historique daté des changements de statut, ni de partager la charge de travail avec le reste du collectif.

### 1.5 Solution proposée

Un outil web de Gestion de la Relation Client (CRM) sur mesure, reposant sur une interface web et une base de données PostgreSQL, permettant de :

- Publier une opportunité commerciale qualifiée via un formulaire structuré ;
- Rendre visibles les opportunités ouvertes à l'ensemble des membres et permettre à chacun de s'y positionner ;
- Suivre le cycle de vie d'une opportunité (7 statuts) jusqu'à sa conversion en mission, avec historique daté ;
- Distinguer deux points de vue : l'apporteur d'affaire (qui publie/apporte l'opportunité) et le preneur d'affaire (qui la prend en charge) ;
- Offrir aux administrateurs une vision transverse de l'activité de chacun sur les opportunités.

L'outil doit être simple à prendre en main, responsive (utilisable sur smartphone), construit avec des technologies libres et « IA-friendly », entièrement en français.

---

## 2. Comprendre l'existant

### 2.1 Solution actuelle

- Un réseau social, sur lequel sont postées les offres clients.
- Une table SQL personnel tenu par le client (colonnes détaillées en section 1.4), servant de suivi commercial de fait.
- Aucun CRM ni outil dédié existant à ce jour.

Un extrait anonymisé des données actuelles a été transmis par mail par le client, de même qu'un export du schéma PostgreSQL existant (à réviser).

### 2.2 Limites identifiées

- Gestion reposant sur une seule personne, difficile à déléguer ou à partager avec le reste du collectif.
- Absence de structuration des opportunités : pas de statuts formalisés, pas d'historique daté des changements.
- Aucune traçabilité de qui a fait quoi sur une opportunité (contact, positionnement, note ajoutée…).
- Pas de distinction entre les contacts d'une opportunité et les membres du collectif.
- Pas de vue partagée des opportunités contactées en dehors du collectif (pour un éventuel recontact).

### 2.3 Fonctionnalités manquantes

- Formulaire structuré de publication d'une opportunité, reprenant un template standardisé (source, besoin, conditions, lieu, timing, candidature, diffusion).
- Gestion des contacts liés à une opportunité, distincte de la gestion des membres du collectif.
- Workflow de statuts (7 étapes) avec historique daté des changements.
- Gestion des rôles (administrateur / membre) et des droits de visibilité associés.
- Suivi de la conversion d'une opportunité en mission, avec affectation d'un freelance et ajout de comptes-rendus.
- Base de profils déjà contactés hors collectif, réservée aux administrateurs.

---

## 3. Besoins fonctionnels

### 3.1 Fonctionnalités indispensables

- Publier une opportunité commerciale via un formulaire structuré (template fourni par le client).
- Consulter la liste des opportunités ouvertes et se positionner sur l'une d'entre elles. Une fois qu'un membre s'est positionné, l'opportunité n'est plus proposée comme disponible aux autres membres (les autres membres peuvent toutefois toujours y ajouter une note).
- Ajouter une note à une opportunité (visible par les membres concernés).
- Faire évoluer le statut d'une opportunité parmi les 7 statuts définis, avec horodatage automatique du changement.
- Conserver un historique complet et daté des changements de statut d'une opportunité.
- Ne jamais supprimer une opportunité, y compris signée ou perdue (conservation en base, pas de suppression physique).
- Convertir une opportunité en mission et lui affecter un ou plusieurs freelances.
- Ajouter des comptes-rendus / rapports au fil d'une mission.
- Gérer les contacts associés à une opportunité (une même personne pouvant être liée à plusieurs opportunités dans le temps).
- Gérer les profils membres (informations personnelles, notes).
- Distinguer les droits administrateur / membre, notamment sur la visibilité des contacts pris hors collectif.
- Lister l'ensemble des entreprises/clients par utilisateur (simple interrogation de la base).

### 3.2 Actions des utilisateurs

#### Membre

- Consulter les opportunités ouvertes.
- Publier une nouvelle opportunité (règle de qui peut publier à confirmer avec le client).
- Se positionner sur une opportunité.
- Faire évoluer le statut d'une opportunité sur laquelle il est positionné.
- Ajouter une note à une opportunité.
- Gérer son propre profil (coordonnées, notes).

#### Administrateur

- Toutes les actions d'un membre.
- Suivre l'évolution du statut d'une opportunité et son historique.
- Consulter qui a été contacté en dehors du collectif (base de profils à recontacter).
- Consulter l'activité de chaque membre sur les opportunités (qui a fait quoi, et quand).

### 3.3 Données à enregistrer

#### Opportunité

| Champ | Description |
| --- | --- |
| Titre / sujet | Intitulé résumant le besoin en une phrase. |
| Source | Origine de l'opportunité (client, commercial, contact, apporteur…). |
| Température | Niveau de maturité de l'opportunité (chaud / tiède). |
| Type de mission | Run / Build / Expertise… |
| Niveau recherché | Opérationnel / Senior / Expert. |
| Client final | Entreprise cliente concernée par la mission. |
| Apporteur | Membre du collectif qui a trouvé l'opportunité et l'a proposée aux autres membres. |
| Moteur | Personne qui recherche un profil hors collectif, le cas échéant. |
| Preneur | Freelance qui prend en charge et gère l'opportunité. |
| TJM client | Taux journalier moyen facturé au client. |
| TJM preneur | Taux journalier moyen versé au freelance preneur. |
| Nombre de jours / durée | Charge estimée ou durée de la mission. |
| Montant facturé | Montant final facturé, une fois la mission actée. |
| Charge | Temps plein / 3-4 jours / 1-2 jours par semaine… |
| Ville / mode | Lieu de la mission et mode de travail (télétravail, hybride, présentiel). |
| Timing | Urgence de la mission (urgent / < 1 mois / > 1 mois). |
| Mode de candidature | Via apporteur / contact direct recruteur / via moteur, avec précision (nom, mail, canal). |
| Niveau de diffusion | Libre / réseau personnel / interne strict. |
| Type de deal | Nature de l'accord commercial. |
| Statut | Un des 7 statuts définis (voir ci-dessous). |
| Date du signal | Date de détection de l'opportunité. |
| Date de clôture | Date de signature ou de perte de l'opportunité. |
| Raison de la perte | Motif en cas de statut « Perdu ». |
| Notes | Informations complémentaires libres. |
| Historique des statuts | Liste datée des changements de statut, avec l'auteur du changement. |

#### Les 7 statuts d'une opportunité

| Statut | Description |
| --- | --- |
| Signal | L'opportunité est détectée, pas encore qualifiée. |
| Matching | L'opportunité est qualifiée, on recherche le profil adapté. |
| Proposé | Un profil a été présenté au client. |
| En discussion | Les conditions sont en cours de négociation. |
| Signé | La mission est actée. |
| Perdu | L'opportunité n'a pas abouti (profil concurrent placé, besoin annulé…). |
| En pause | Le client reporte sa décision ; l'opportunité sera relancée plus tard. |

#### Contact lié à une opportunité

| Champ | Description |
| --- | --- |
| Nom, Prénom | Identité du contact. |
| Rôle | Fonction chez le client (commercial, responsable data…). |
| Entreprise | Société du contact. |
| Mail | Adresse mail de contact. |
| Téléphone | Optionnel selon les cas. |

_Un même contact peut être lié à plusieurs opportunités au fil du temps._

#### Membre (profil utilisateur)

| Champ | Description |
| --- | --- |
| Nom, Prénom | Identité du membre (champ obligatoire). |
| Mail | Adresse mail (champ obligatoire). |
| Téléphone | Optionnel. |
| Notes | Zone de notes libres. |
| Rôle | Administrateur ou membre. |
| Ville | Champ texte, avec une validation a minima du format (ex. code postal). |

_Compétences : hors périmètre à ce stade (évolution possible plus tard). Si la matrice de compétences (actuellement un Google Sheet) est intégrée, elle prendra la forme d'une table dédiée, distincte du profil membre, associant la clé primaire du freelance à chacune de ses compétences avec son niveau (note de 1 à 4) — plutôt qu'un champ libre sur le profil membre, afin de rester exploitable (filtrage, matching)._

_L'historique des clients déjà sollicités par chaque membre est également hors périmètre à ce stade et pourra être intégré comme évolution possible plus tard._

### 3.4 Résultats attendus

- Un outil unique et centralisé, qui remplace les offres d'opportunité sur le réseau social interne et le tableur personnel du client.
- Une adoption large par le collectif (au-delà des 4-5 personnes actuelles), grâce à une prise en main facile au quotidien.
- Une meilleure visibilité des opportunités ouvertes pour l'ensemble des membres, et une meilleure traçabilité de l'activité commerciale pour les administrateurs.
- Un historique fiable et daté du cycle de vie de chaque opportunité, jusqu'à sa conversion (ou non) en mission.
- Une documentation technique solide, permettant au client de reprendre la main sur l'outil après la livraison.

---

## 4. Besoins non fonctionnels

| Critère | Détail |
| --- | --- |
| Facilité d'utilisation | Priorité n°1 du client : l'outil doit être facile à prendre en main pour fédérer un maximum de membres du collectif. |
| Responsive | Application web utilisable confortablement sur smartphone, en plus du poste de travail. |
| Simplicité technique | Stack volontairement simple : interface web + base de données PostgreSQL, API non indispensable dans un premier temps (évolution possible). |
| Technologies libres | Le client souhaite pouvoir reprendre la solution : usage d'outils open source privilégié. |
| IA-friendly | La solution doit pouvoir s'intégrer facilement à des usages ou outils d'intelligence artificielle par la suite. |
| Langue | Interface intégralement en français. |
| Hébergement | VPS |
| Accès | Application accessible en ligne (site web public), sans nécessité de VPN ou de réseau privé. |
| Conservation des données | Aucune suppression : les opportunités signées ou perdues restent consultables en base. |
| Documentation | Documentation technique complète et détaillée, pour assurer la maintenabilité de l'outil par le client. |
| Passage à l'échelle | L'outil doit pouvoir accueillir davantage de membres que les ~50 utilisateurs actuels. |

---

## 5. Contraintes et limites

- Le schéma PostgreSQL existant doit être révisé, il n'est pas directement réutilisable en l'état.
- Une version V0 doit être développée et validée en local avant toute mise à disposition d'un VPS de production.
- Le reporting et les statistiques (nombre de leads, taux de conversion, activité par collaborateur) ne sont pas demandés dans ce périmètre : le client dispose déjà d'un outil d'IA pour ce besoin.
- Les notifications/rappels de relance sont une option intéressante mais non tranchée : à la charge de l'équipe projet de proposer une solution.
- La nécessité d'une API n'est pas imposée : à évaluer par l'équipe projet selon l'architecture retenue.
- La ville est intégrée au profil membre (champ texte avec validation de format a minima).
- La matrice de compétences (Google Sheet) et l'historique des clients déjà démarchés sont hors périmètre à ce stade (évolution possible plus tard). Si elle est intégrée, la matrice de compétences prendra la forme d'une table dédiée (clé primaire du freelance associée à ses compétences et à leur niveau), et non d'un champ libre sur le profil membre.
- La répartition précise des droits admin / membre reste à affiner avec deux autres interlocuteurs côté client (Grégory et Anaël).
- Les règles de transition entre les 7 statuts d'une opportunité (qui peut déclencher quel changement, retours en arrière possibles ou non, statuts pouvant être sautés) restent à préciser avec le client afin de définir les limites exactes du workflow.
- À voir avec le client si une politique de journalisation de l'historique des statuts (archivage annuel ou autre) est nécessaire en cas de volume important.
- À voir avec le client si des pièces jointes doivent être associées aux contacts et/ou aux comptes-rendus de mission (ex. documents, PDF) — impact potentiel sur le stockage au-delà de la seule base PostgreSQL.
- Les notifications / rappels de relance ne sont pas une priorité pour le moment ; à envisager comme évolution possible plus tard.

---

## 6. Persona

Deux profils distincts coexistent au sein de l'outil : l'administrateur et le membre.

### Administrateur

Fait partie de la cellule commerce de Koloni (4-5 personnes). Gère la relation commerciale sans exécuter lui-même les missions.

| Attribut | Détail |
| --- | --- |
| Effectif | 4 à 5 personnes. |
| Rôle | Trouver et suivre les opportunités commerciales, faire évoluer leur statut. |
| Droits spécifiques | Voit qui a été contacté en dehors du collectif (base de profils à recontacter) ; consulte l'activité de chaque membre sur les opportunités. |
| Actions clés | Publier / qualifier une opportunité, la faire évoluer, la convertir en mission, affecter un freelance, consulter l'historique. |

### Membre

Freelance du collectif Koloni, susceptible de se positionner sur une opportunité ou d'être affecté à une mission.

| Attribut | Détail |
| --- | --- |
| Effectif | Environ 50 personnes, avec ouverture possible à d'autres membres par la suite. |
| Rôle | Consulter les opportunités ouvertes, se rendre visible et se positionner sur une mission. |
| Droits | Voit les opportunités, peut s'y positionner ou y ajouter une note. Le droit de publier une opportunité reste à confirmer. |
| Actions clés | Consulter les opportunités, se positionner, ajouter une note, gérer son profil (coordonnées, notes). |

---

## 7. Use Cases

| # | Cas d'utilisation | Acteur |
| --- | --- | --- |
| UC1 | Publier une opportunité commerciale | Membre / Administrateur |
| UC2 | Consulter les opportunités ouvertes | Membre, Administrateur |
| UC3 | Se positionner sur une opportunité | Membre, Administrateur |
| UC4 | Ajouter une note à une opportunité | Membre, Administrateur |
| UC5 | Faire évoluer le statut d'une opportunité | Membre affecté, Administrateur |
| UC6 | Consulter l'historique des statuts d'une opportunité | Administrateur |
| UC7 | Convertir une opportunité en mission | Membre, Administrateur |
| UC8 | Ajouter un compte-rendu à une mission | Administrateur, Membre affecté |
| UC9 | Consulter la base de profils contactés hors collectif | Administrateur |
| UC10 | Gérer son profil membre | Membre |

---

## 8. User Stories

### UC1 — Publier une opportunité
>
> En tant que membre du collectif, je veux publier une opportunité commerciale via un formulaire structuré (source, besoin, conditions, lieu, timing, candidature, diffusion), afin que les autres membres puissent la consulter et se positionner dessus.

### UC3 — Se positionner sur une opportunité
>
> En tant que membre, je veux pouvoir me positionner sur une opportunité ouverte, afin de me rendre visible auprès de l'apporteur et signaler mon intérêt pour la mission. Une fois positionnée, l'opportunité n'est plus proposée comme disponible aux autres membres, qui conservent néanmoins la possibilité d'y ajouter une note.

### UC5 — Faire évoluer le statut d'une opportunité
>
> En tant qu'administrateur, je veux faire évoluer le statut d'une opportunité parmi les 7 statuts définis, afin de suivre son avancement et de conserver un historique daté de son cycle de vie.

### UC7 — Convertir une opportunité en mission
>
> En tant qu'administrateur, je veux convertir une opportunité signée en mission et lui affecter un freelance, afin de pouvoir suivre son exécution et centraliser les comptes-rendus associés.

---

## 9. Priorités

### 9.1 Fonctionnalités obligatoires

- Publication d'une opportunité via un formulaire structuré.
- Consultation des opportunités ouvertes et positionnement des membres.
- Workflow des 7 statuts avec historique daté des changements.
- Conservation permanente des opportunités (aucune suppression).
- Gestion des contacts liés à une opportunité.
- Gestion des profils membres (nom, prénom, mail, téléphone optionnel, notes).
- Distinction des droits administrateur / membre.
- Conversion d'une opportunité en mission, avec affectation d'un freelance et ajout de comptes-rendus.
- Interface responsive, en français, simple à prendre en main.
- Documentation technique complète.

### 9.2 Fonctionnalités souhaitées

- Notifications / rappels automatiques pour les relances.
- Intégration de la matrice de compétences (actuellement sur Google Sheet), sous forme d'une table dédiée associant la clé primaire du freelance à ses compétences et à leur niveau (note de 1 à 4), plutôt qu'un champ libre sur le profil membre.
- Historique des clients déjà démarchés par chaque membre.

### 9.3 Fonctionnalités optionnelles / évolutions possibles

- Exposition d'une API : non indispensable dans un premier temps, à évaluer selon l'architecture retenue.
- Gestion de pièces jointes sur les contacts et/ou les comptes-rendus de mission (ex. documents, PDF) — impact potentiel sur le stockage au-delà de la seule base PostgreSQL.
- Politique de journalisation / archivage de l'historique des statuts (par exemple annuel) si le volume d'opportunités devient important.
