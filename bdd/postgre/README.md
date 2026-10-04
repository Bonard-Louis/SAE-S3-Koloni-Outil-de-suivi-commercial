# Base de données PostgreSQL (Docker)

Base PostgreSQL 16 du CRM Koloni, lancée en local avec Docker Compose. Au premier démarrage, elle crée le schéma puis charge un jeu de données de test fictif.

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installé et **démarré**.

## Configuration

Depuis ce dossier (`bdd/postgre`), créer le fichier d'environnement local :

```bash
cp .env.example .env
```

Puis remplacer la valeur de `POSTGRES_PASSWORD` dans `.env`. Le fichier `.env` n'est jamais commité.

| Variable | Défaut | Rôle |
| --- | --- | --- |
| `POSTGRES_DB` | `koloni` | Nom de la base. |
| `POSTGRES_USER` | `koloni_app` | Utilisateur de la base. |
| `POSTGRES_PASSWORD` | aucun (obligatoire) | Mot de passe de l'utilisateur. |
| `POSTGRES_PORT` | `5432` | Port publié sur la machine. À changer si un autre Postgres utilise déjà le 5432. |

## Lancer la base

```bash
docker compose up -d --build
```

Le conteneur `koloni_postgres` démarre en arrière-plan. Pour vérifier qu'il est prêt :

```bash
docker compose ps
```

La colonne `STATUS` doit afficher `healthy`.

La base n'est accessible que depuis la machine locale (`127.0.0.1`), pas depuis le réseau.

## Se connecter

```bash
docker exec -it koloni_postgres psql -U koloni_app -d koloni
```

Quelques commandes utiles dans `psql` : `\dt` (liste des tables), `\d opportunite` (détail d'une table), `\q` (quitter).

## Connecter l'application Nuxt

Dans `crm-koloni/.env`, renseigner les mêmes valeurs que `bdd/postgre/.env` :

```text
NUXT_DATABASE_HOST=localhost
NUXT_DATABASE_PORT=5432
NUXT_DATABASE_NAME=koloni
NUXT_DATABASE_USER=koloni_app
NUXT_DATABASE_PASSWORD=<POSTGRES_PASSWORD>
```

Après `bun run dev`, la page <http://localhost:3000/api/health> doit afficher `"status": "ok"`.

## Arrêter la base

| Commande | Effet |
| --- | --- |
| `docker compose stop` | Arrête le conteneur, les données sont conservées. |
| `docker compose down` | Supprime le conteneur, les données sont conservées (volume `koloni_pgdata`). |
| `docker compose down -v` | Supprime le conteneur **et les données**. |

## Réinitialiser la base

Les scripts SQL ne s'exécutent qu'à la **première initialisation** du volume. Pour repartir d'une base vide, avec le schéma et les données de test :

```bash
docker compose down -v
docker compose up -d --build
```

Même chose après toute modification de `001_creation_schema_koloni.sql` ou de `002_donnees_test.sql`.

## Contenu du dossier

| Fichier | Rôle |
| --- | --- |
| `Dockerfile` | Image `postgres:16-alpine` qui embarque les scripts SQL. |
| `docker-compose.yml` | Service, port, volume de données et healthcheck. |
| `.env.example` | Modèle des variables d'environnement. |
| `001_creation_schema_koloni.sql` | Création du schéma (tables, contraintes, triggers). |
| `002_donnees_test.sql` | Données de test fictives (membres, contacts, opportunités…). |

Les scripts `*.sql` sont exécutés dans l'ordre alphabétique de leur nom.

## Problèmes fréquents

- **`Cannot connect to the Docker daemon`** : Docker Desktop n'est pas démarré.
- **`port is already allocated`** : un autre programme utilise le port 5432. Changer `POSTGRES_PORT` dans `.env` (par exemple `5433`) et reporter la valeur dans `NUXT_DATABASE_PORT`.
- **`POSTGRES_PASSWORD` : erreur au lancement** : la variable n'est pas définie, vérifier que `.env` existe dans ce dossier.
- **Le mot de passe modifié n'est pas pris en compte** : Postgres ne lit le mot de passe qu'à la création du volume. Réinitialiser la base (voir plus haut).
