# SAE-S3-Koloni-Outil-de-suivi-commercial

## Équipe & Rôles

* **Garaios Mathias** - *Scrum Master*
* **Drapied Hugo** - *Product Owner*
* **Martinez Lucie** - *Developer*
* **Fellah Sara** - *Developer*
* **Bonard Louis** - *Developer*

---

## À propos du projet

**Koloni** est un réseau professionnel national tourné vers les freelances en Data, ayant pour objectif principal le partage de connaissances et d'opportunités professionnelles.

Actuellement, les membres font circuler des opportunités de mission et relancent des contacts de manière isolée, avec leurs propres notes, sans centralisation ni partage.

### Objectifs de l'application

* Suivre centralement les contacts et les leads.
* Gérer des relances datées et des rappels.
* Assurer un suivi précis du statut par opportunité.
* Visualiser clairement ce qui se transforme en mission au bout du compte.

A completer après le rdv avec le client

---

## Technologies utilisés

* **Base de données :** PostgreSQL
* **Backend :** NUXT
* **Frontend :** NUXT

---

## Structure du Repository

```text
.
├── bdd/
│   ├── postgre/            # Scripts SQL versionnés (001_, 002_, ... appliqués dans l'ordre)
│   └── data/                # Données de dev, ignorées par git (non versionnées)
├── documentation/
│   └── GLOSSAIRE.md         # Documentation du schéma de base de données
├── recueil-de-besoin/
│   ├── Cahier des charges.md
│   ├── Recueil_de_Besoins.md
│   └── maquettes/            # Maquettes des écrans (images)
└── README.md
```

---

## Conventions

### Nommage

* Dossiers en `kebab-case` minuscule, sans espace ni accent (ex. `recueil-de-besoin/`, `documentation/`).
* Scripts SQL numérotés séquentiellement (`001_`, `002_`, ...) et appliqués dans l'ordre — voir `documentation/GLOSSAIRE.md`.

### Commits

Convention inspirée de [Conventional Commits](https://www.conventionalcommits.org/), message rédigé en français :

```text
type: résumé court à l'indicatif

Corps optionnel expliquant le pourquoi, si le résumé ne suffit pas.
```

Types utilisés : `feat` (fonctionnalité), `fix` (correction), `docs` (documentation), `chore` (outillage/réorganisation), `refactor` (restructuration sans changement de comportement).

---

## Utilisation de l'IA

L'équipe utilise une IA (ex: Claude Code, d'Anthropic) comme assistant de développement.

### Usages

* **Tests :** création de tests de la base de données, et tests en tant qu'utilisateur par une IA agentique qui pilote le navigateur (connexion, saisie des formulaires, vérification des écrans).
* **Données de test :** génération de jeux de données fictifs (opportunités, contacts, profils).
* **Correction de bugs :** recherche de la cause d'une erreur et proposition d'un correctif.
* **Composants :** aide à l'utilisation des composants Nuxt UI et de leurs options.
* **Qualité du code :** relecture, simplification, commentaires et documentation des composants.
* **Typage et lint :** renforcement du typage TypeScript et correction des erreurs `eslint` et `ruff`.
* **Code mort :** repérage des fichiers, fonctions et dépendances inutilisés.
* **Compréhension du code :** explication d'une partie du code à un membre qui la découvre.
* **Sécurité et DevOps :** recherche de failles de sécurité (tests d'intrusion sur l'application en local), audit des dépendances, configuration de Docker et de l'environnement de déploiement.
* **Dépendances :** choix et blocage des versions, mises à jour limitées aux correctifs de sécurité.
* **Git :** gestion des pulls, merges et rebases, des branches et des stash, correction de l'historique.
* **Commits :** découpage des changements et rédaction des messages selon la convention ci-dessus.
* **Suivi du projet :** comparaison de l'avancement avec le cahier des charges, mise à jour du découpage en releases, organisation des issues GitHub (une issue par exigence).
* **Documentation :** rédaction et relecture des documents du projet, intégration des retours du client dans le recueil de besoins et le cahier des charges.

### Règles

* Chaque proposition de l'IA est relue et validée par un membre de l'équipe avant d'être appliquée, commitée ou publiée.
* Les tests se font uniquement sur les données fictives du projet.
* Aucun secret de production n'est transmis à l'IA ; seuls des comptes et des valeurs de test sont utilisés.
