// useOpportuniteBadges — couleurs des pastilles technologie + construction des BadgeItem
// Partagé entre les vues listant des opportunités (liste principale, vues filtrées)

// Colonnes fixes du tableau — ordre, clé (= tooltip du badge) et largeur partagés avec TableauOpportunites
export const OPPORTUNITE_BADGE_COLUMNS = [
  { key: 'Client final', label: 'Client', width: 'w-32' },
  { key: 'Ville', label: 'Ville', width: 'w-28' }
] as const

const BADGE_PALETTE: NuxtUiColor[] = [
  'secondary', 'violet', 'pink', 'orange', 'teal',
  'cyan', 'rose', 'indigo', 'lime', 'fuchsia', 'purple'
]

// buildColorMap : associe chaque valeur unique à une couleur fixe de la palette (triées alphabétiquement,
// cyclées si plus de 11 valeurs) — garantit une couleur stable quelle que soit l'ordre des données
function buildColorMap(values: (string | undefined)[]): Record<string, NuxtUiColor> {
  const unique = [...new Set(values.filter(Boolean) as string[])].sort()
  return Object.fromEntries(unique.map((v, i) => [v, BADGE_PALETTE[i % BADGE_PALETTE.length]!]))
}

export function useOpportuniteBadges(opportunites: Ref<Opportunite[] | null | undefined>) {
  const technologieColors = computed(() => buildColorMap((opportunites.value ?? []).flatMap(o => o.technologies ?? [])))

  // getOpportuniteBadges : construit la liste des pastilles pour une opportunité donnée.
  // Chaque champ vide/undefined est ignoré — aucune pastille vide n'est affichée.
  function getOpportuniteBadges(o: Opportunite): BadgeItem[] {
    const badges: BadgeItem[] = []
    for (const techno of o.technologies ?? []) {
      badges.push({
        label: techno,
        color: technologieColors.value[techno] ?? 'secondary',
        to: `/opportunites?technologie=${encodeURIComponent(techno)}`
      })
    }
    if (o.ville) {
      badges.push({ label: o.ville, color: 'neutral', icon: 'i-lucide-map-pin', tooltip: 'Ville' })
    }
    if (o.mode) {
      badges.push({ label: o.mode, color: 'neutral', icon: 'i-lucide-laptop', tooltip: 'Mode' })
    }
    if (o.clientFinal) {
      badges.push({ label: o.clientFinal, color: 'neutral', icon: 'i-lucide-building-2', tooltip: 'Client final' })
    }
    return badges
  }

  return { technologieColors, getOpportuniteBadges }
}
