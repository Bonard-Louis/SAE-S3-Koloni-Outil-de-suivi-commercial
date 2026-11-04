import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'

const params = z.object({
  id: z.string().regex(/^\d+$/)
})

interface LigneOpportunite {
  apporteur_id: string
  statut: string
  qualifiee_par_id: string | null
}

export default defineEventHandler(async (event) => {
  const session = await exigerSession(event)
  const { id } = await getValidatedRouterParams(event, params.parse)

  try {
    return await enTransaction(event, session.user.id, async (tx) => {
      const [opportunite] = await tx<LigneOpportunite[]>`
        SELECT apporteur_id::text, statut, qualifiee_par_id::text
        FROM opportunite
        WHERE id = ${id}
        FOR UPDATE
      `
      if (!opportunite) {
        throw createError({ statusCode: 404, statusMessage: 'Opportunité introuvable' })
      }

      if (session.role !== Role.admin && session.user.id !== opportunite.apporteur_id) {
        throw createError({ statusCode: 403, statusMessage: 'Seul l’apporteur ou un administrateur peut qualifier cette opportunité' })
      }

      if (opportunite.statut !== 'signal' || opportunite.qualifiee_par_id !== null) {
        throw createError({ statusCode: 409, statusMessage: 'Seule une opportunité non qualifiée au statut Signal peut être qualifiée' })
      }

      await tx`
        UPDATE opportunite
        SET statut = 'matching',
            qualifiee_par_id = ${session.user.id},
            date_qualification = now()
        WHERE id = ${id}
      `

      return { id, statut: 'Matching' }
    })
  } catch (error) {
    throw erreurSql(error)
  }
})
