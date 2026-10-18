// Totaux affichés en tête de la page d'administration : membres actifs, désactivés, administrateurs, par disponibilité
import type { CompteursComptes } from '#shared/types/utilisateur'

interface LigneCompteurs {
  actifs: number
  desactives: number
  administrateurs: number
  en_recherche: number
  en_mission: number
}

export default defineEventHandler(async (event): Promise<CompteursComptes> => {
  await exigerAdmin(event)
  const sql = useDb(event)

  const [ligne] = await sql<LigneCompteurs[]>`
    SELECT
      count(*) FILTER (WHERE actif)::int                                        AS actifs,
      count(*) FILTER (WHERE NOT actif)::int                                    AS desactives,
      count(*) FILTER (WHERE actif AND role = 'administrateur')::int            AS administrateurs,
      count(*) FILTER (WHERE actif AND disponibilite = 'en_recherche')::int     AS en_recherche,
      count(*) FILTER (WHERE actif AND disponibilite = 'en_mission')::int       AS en_mission
    FROM membre
  `

  return {
    actifs: ligne!.actifs,
    desactives: ligne!.desactives,
    administrateurs: ligne!.administrateurs,
    enRecherche: ligne!.en_recherche,
    enMission: ligne!.en_mission
  }
})
