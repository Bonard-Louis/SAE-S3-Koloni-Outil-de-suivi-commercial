/**
 * Libellés d'affichage des valeurs stockées en base (codes sans accent) et mise en forme des lignes
 */

const STATUTS: Record<string, string> = {
  signal: 'Signal',
  matching: 'Matching',
  propose: 'Proposé',
  en_discussion: 'En discussion',
  signe: 'Signé',
  perdu: 'Perdu',
  en_pause: 'En pause'
}

const TEMPERATURES: Record<string, string> = {
  chaud: 'Chaud',
  tiede: 'Tiède'
}

const MODES: Record<string, string> = {
  teletravail: 'Télétravail',
  hybride: 'Hybride',
  presentiel: 'Présentiel'
}

export const libelleStatut = (code: string) => STATUTS[code]!
export const libelleTemperature = (code: string | null) => (code ? TEMPERATURES[code] : undefined)
export const libelleMode = (code: string | null) => (code ? MODES[code] : undefined)

// Les colonnes vides arrivent en null ; les types du front attendent des champs absents (undefined)
export const nullEnUndefined = (valeur: string | null) => valeur ?? undefined
