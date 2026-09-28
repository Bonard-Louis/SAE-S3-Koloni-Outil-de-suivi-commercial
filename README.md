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
* **Backend :
* **Frontend :

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
