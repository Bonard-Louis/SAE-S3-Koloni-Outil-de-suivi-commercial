// StatutOpportunite — les 7 statuts du cycle de vie d'une opportunité (recueil de besoins §3.3)
type StatutOpportunite = 'Signal' | 'Matching' | 'Proposé' | 'En discussion' | 'Signé' | 'Perdu' | 'En pause'

// Temperature — niveau de maturité d'une opportunité (recueil de besoins §3.3)
type Temperature = 'Chaud' | 'Tiède'

// Opportunite — opportunité commerciale suivie dans le CRM
interface Opportunite {
  id: string
  titre: string // intitulé résumant le besoin
  statut: StatutOpportunite
  technologies?: string[] // technologies demandées
  ville?: string
  mode?: string // télétravail / hybride / présentiel
  clientFinal?: string // entreprise où se déroule la mission, si connue
  apporteur: string // membre qui amène l'opportunité (obligatoire)
  temperature?: Temperature
  dateSignal: string // date de détection de l'opportunité (AAAA-MM-JJ)
}

// NuxtUiColor — couleurs acceptées par les composants Nuxt UI (UBadge, UButton…)
type NuxtUiColor = 'primary' | 'secondary' | 'success' | 'info' | 'warning' | 'error' | 'neutral'
  | 'violet' | 'pink' | 'orange' | 'teal' | 'cyan' | 'rose' | 'indigo' | 'lime' | 'fuchsia' | 'purple'

// BadgeItem — pastille affichée dans TableauOpportunites
interface BadgeItem {
  label: string // texte affiché
  color: NuxtUiColor // couleur Nuxt UI
  icon?: string // icône affichée avant le label (nom Iconify)
  trailingIcon?: string // icône affichée après le label (nom Iconify)
  tooltip?: string // infobulle au survol sur desktop
  to?: string // si présent : pastille cliquable (NuxtLink)
}

// PersonneListee — personne affichée dans une liste de puces supprimables (ListePersonnes)
interface PersonneListee {
  id: string
  mail: string
  nom: string
  prenom: string
}
