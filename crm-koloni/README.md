# CRM Koloni

Application web du CRM interne KOLONI — Nuxt 4 + Nuxt UI 4 + Bun.

## Installation

Prérequis : [Bun](https://bun.sh) installé.

```bash
bun install
```

## Configuration

Créer le fichier d'environnement local à partir de l'exemple :

```bash
cp .env.example .env
```

Renseigner `NUXT_SESSION_PASSWORD` avec une chaîne aléatoire d'au moins 32 caractères, par exemple :

```bash
openssl rand -hex 32
```

## Démarrage

```bash
bun run dev
```

L'application est alors accessible sur [http://localhost:3000](http://localhost:3000). Toute navigation redirige vers `/login` tant que l'utilisateur n'est pas connecté (middleware d'authentification global).

## Scripts disponibles

| Commande | Description |
| --- | --- |
| `bun run dev` | Lance le serveur de développement. |
| `bun run build` | Build de production. |
| `bun run preview` | Prévisualise le build de production en local. |
| `bun run typecheck` | Vérifie les types (`nuxt typecheck`). |
| `bun run lint` | Vérifie le style et les erreurs (`eslint .`). |

## Composants réutilisables (`app/components/`)

### `MenuApplication`

En-tête de navigation principal (desktop + mobile), avec les entrées adaptées au rôle de l'utilisateur connecté (l'entrée « Comptes » n'apparaît que pour un administrateur).

- Pas de props.
- Dépend de `useAuth()` (voir plus bas).

```vue
<template>
  <UApp>
    <MenuApplication />
    <NuxtPage />
  </UApp>
</template>
```

### `InfoUtilisateur`

Affiche le nom complet et le rôle (« Administrateur » / « Membre ») de l'utilisateur connecté. À n'afficher que si `isAuthenticated`.

- Pas de props.
- Dépend de `useAuth()`.

```vue
<InfoUtilisateur v-if="isAuthenticated" />
```

### `CarteTitree`

`UCard` avec un en-tête standardisé (icône + titre).

| Prop | Type | Description |
| --- | --- | --- |
| `icon` | `string` | Nom de l'icône Iconify (ex. `i-lucide-briefcase`). |
| `title` | `string` | Titre affiché dans l'en-tête. |

Slot par défaut : contenu de la carte.

```vue
<CarteTitree icon="i-lucide-briefcase" title="Opportunités en cours">
  <p>Contenu de la carte…</p>
</CarteTitree>
```

### `TableauOpportunites`

Tableau d'opportunités réutilisable (liste principale et vues filtrées), basé sur `UTable`. La barre colorée à gauche et le badge de statut reflètent le `StatutOpportunite` de chaque ligne ; les colonnes intermédiaires affichent des pastilles (`BadgeItem`) configurables.

| Prop | Type | Description |
| --- | --- | --- |
| `opportunites` | `Opportunite[]` | Données à afficher. |
| `getBadges` | `(o: Opportunite) => BadgeItem[]` | Fonction retournant les pastilles d'une opportunité (voir `useOpportuniteBadges`). |
| `columns?` | `string[]` | Sous-ensemble de clés de `OPPORTUNITE_BADGE_COLUMNS` à afficher ; toutes par défaut. |
| `titreTo?` | `(o: Opportunite) => string` | Lien cliquable sur le titre (optionnel). |

```vue
<script setup lang="ts">
const { getOpportuniteBadges } = useOpportuniteBadges(opportunites)
</script>

<template>
  <TableauOpportunites
    :opportunites="opportunites"
    :get-badges="getOpportuniteBadges"
    :titre-to="o => `/opportunites/${o.id}`"
  />
</template>
```

### `BarrePagination`

Barre de pagination centrée, autour de `UPagination`.

| Prop | Type | Description |
| --- | --- | --- |
| `page` | `number` | Page courante. |
| `total` | `number` | Nombre total d'éléments. |
| `itemsPerPage` | `number` | Éléments affichés par page. |

Émet `update:page` (compatible `v-model:page`).

```vue
<BarrePagination v-model:page="page" :total="total" :items-per-page="20" />
```

### `ListeDeroulanteLibellee`

Libellé + `USelect`, dont la largeur s'ajuste automatiquement à l'option la plus longue.

| Prop | Type | Description |
| --- | --- | --- |
| `label` | `string` | Libellé affiché au-dessus du sélecteur. |
| `items` | `(string \| { label: string, value: string \| number \| boolean })[]` | Options proposées. |
| `placeholder?` | `string` | Texte affiché sans sélection. |
| `description?` | `string` | Texte explicatif sous le sélecteur. |

Utilise `defineModel` (compatible `v-model`).

```vue
<ListeDeroulanteLibellee
  v-model="statutChoisi"
  label="Statut"
  :items="['Signal', 'Matching', 'Proposé']"
  placeholder="Tous les statuts"
/>
```

### `ListePersonnes`

Liste de personnes affichées en puces, avec suppression individuelle. Ne s'affiche pas si `personnes` est vide.

| Prop | Type | Description |
| --- | --- | --- |
| `personnes` | `PersonneListee[]` | Personnes à afficher. |
| `label` | `string` | Titre du groupe. |
| `color?` | `'primary' \| 'secondary'` | Couleur des puces (`primary` par défaut). |
| `display?` | `'nomComplet' \| 'mail'` | Champ affiché sur chaque puce (`nomComplet` par défaut). |

Émet `remove` avec la personne concernée.

```vue
<ListePersonnes
  :personnes="positionnes"
  label="Membres positionnés"
  display="nomComplet"
  @remove="p => retirerPositionnement(p)"
/>
```

## Composables (`app/composables/`)

### `useAuth()`

Expose l'état d'authentification courant à partir de `nuxt-auth-utils` : `isAuthenticated`, `user`, `role`, `isAdmin`, `session`, ainsi que `refresh()` et `logout()`.

### `useOpportuniteBadges(opportunites)`

Construit les pastilles (`BadgeItem`) d'une liste d'opportunités, avec une couleur stable par valeur (technologie, ville, mode, client final). Expose `technologieColors` et `getOpportuniteBadges(o)`, à passer en prop `getBadges` de `TableauOpportunites`.

## Types partagés

- `shared/types/utilisateur.ts` : `Role` (`admin` / `membre`) et `Utilisateur`.
- `app/types/index.d.ts` : `StatutOpportunite`, `Opportunite`, `BadgeItem`, `NuxtUiColor`, `PersonneListee`.
