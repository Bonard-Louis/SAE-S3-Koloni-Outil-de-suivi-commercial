<!--
  TableauOpportunites — tableau d'opportunités réutilisable (liste principale + vues filtrées)
  Encapsule UTable (TanStack Table) avec un système de colonnes de pastilles configurable.
  Props :
    opportunites — données à afficher
    getBadges    — fonction qui retourne les BadgeItem d'une opportunité
    columns      — sous-ensemble de clés OPPORTUNITE_BADGE_COLUMNS à afficher ; défaut = toutes
    titreTo      — fonction qui retourne le lien du titre (optionnel)
-->
<template>
  <UTable
    :data="opportunites"
    :columns="tableColumns"
    :ui="{
      th: 'text-[10px] uppercase tracking-wide text-gray-400 dark:text-gray-500 py-1',
      td: 'py-2 align-middle'
    }"
  />
</template>

<script lang="ts" setup>
import { h, resolveComponent } from 'vue'

const props = defineProps<{
  opportunites: Opportunite[]
  getBadges: (o: Opportunite) => BadgeItem[]
  columns?: string[]
  titreTo?: (o: Opportunite) => string
}>()

const STATUT_BAR: Record<StatutOpportunite, string> = {
  'Signal': 'bg-gray-400',
  'Matching': 'bg-info-500',
  'Proposé': 'bg-warning-500',
  'En discussion': 'bg-warning-500',
  'Signé': 'bg-success-500',
  'Perdu': 'bg-error-500',
  'En pause': 'bg-neutral-400'
}

const STATUT_COLOR: Record<StatutOpportunite, NuxtUiColor> = {
  'Signal': 'neutral',
  'Matching': 'info',
  'Proposé': 'warning',
  'En discussion': 'warning',
  'Signé': 'success',
  'Perdu': 'error',
  'En pause': 'neutral'
}

function badgeMap(o: Opportunite): Record<string, BadgeItem> {
  return Object.fromEntries(props.getBadges(o).map(b => [b.tooltip ?? b.label, b]))
}

const visibleBadgeCols = computed(() =>
  props.columns
    ? OPPORTUNITE_BADGE_COLUMNS.filter(c => props.columns!.includes(c.key))
    : OPPORTUNITE_BADGE_COLUMNS
)

const tableColumns = computed(() => {
  const UBadge = resolveComponent('UBadge')
  const UTooltip = resolveComponent('UTooltip')
  const NuxtLink = resolveComponent('NuxtLink')

  return [
    // Trait coloré (barre de statut gauche simulée par une colonne sans en-tête)
    {
      id: 'bar',
      header: '',
      meta: { class: { th: 'w-1 p-0', td: 'w-1 p-0 pr-2' } },
      cell: ({ row }: { row: { original: Opportunite } }) =>
        h('div', { class: ['w-1 rounded-sm self-stretch', STATUT_BAR[row.original.statut] ?? 'bg-gray-400'], style: 'min-height: 2rem' })
    },

    // Titre
    {
      accessorKey: 'titre',
      header: 'Titre',
      cell: ({ row }: { row: { original: Opportunite } }) => {
        const o = row.original
        const to = props.titreTo?.(o)
        return to
          ? h(NuxtLink, { to, class: 'font-medium text-sm text-gray-900 dark:text-white hover:underline truncate' }, () => o.titre)
          : h('p', { class: 'font-medium text-sm text-gray-900 dark:text-white truncate' }, o.titre)
      }
    },

    // Colonnes de pastilles (sous-ensemble selon la prop `columns`)
    ...visibleBadgeCols.value.map(col => ({
      id: col.key,
      header: col.label,
      meta: { class: { th: `${col.width} text-center`, td: `${col.width} text-center` } },
      cell: ({ row }: { row: { original: Opportunite } }) => {
        const badge = badgeMap(row.original)[col.key]
        if (!badge) return null
        const badgeEl = h(UBadge, {
          color: badge.color,
          leadingIcon: badge.icon,
          trailingIcon: badge.trailingIcon,
          variant: 'soft',
          size: 'md'
        }, () => badge.label)
        const inner = badge.to ? h(NuxtLink, { to: badge.to }, () => badgeEl) : badgeEl
        return h(UTooltip, { text: col.label }, () => inner)
      }
    })),

    // Statut
    {
      id: 'statut',
      header: 'Statut',
      meta: { class: { th: 'w-28 text-center', td: 'w-28 text-center' } },
      cell: ({ row }: { row: { original: Opportunite } }) => {
        const o = row.original
        return h(UBadge, {
          color: STATUT_COLOR[o.statut],
          variant: 'solid',
          size: 'md'
        }, () => o.statut)
      }
    }
  ]
})
</script>
