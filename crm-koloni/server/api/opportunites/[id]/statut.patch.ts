import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'

const params = z.object({
  id: z.string().regex(/^\d+$/)
})

const schema = z.object({
  statut: z.enum(codesDe(LIBELLES_STATUT)),
  raisonPerte: z.string().trim().min(1).optional(),
  dateRelance: z.iso.date().optional()
}).superRefine((donnees, contexte) => {
  if (donnees.statut === 'perdu' && !donnees.raisonPerte) {
    contexte.addIssue({
      code: 'custom',
      path: ['raisonPerte'],
      message: 'La raison de la perte est obligatoire'
    })
  }
  if (donnees.statut === 'en_pause' && !donnees.dateRelance) {
    contexte.addIssue({
      code: 'custom',
      path: ['dateRelance'],
      message: 'La date de relance est obligatoire pour une opportunité en pause'
    })
  }
})

interface LigneOpportunite {
  statut: string
  apporteur_id: string
  moteur_id: string | null
  qualifiee_par_id: string | null
  est_positionne: boolean
}

export default defineEventHandler(async (event) => {
  const session = await exigerSession(event)
  const { id } = await getValidatedRouterParams(event, params.parse)
  const donnees = await lireCorps(event, schema)

  try {
    return await enTransaction(event, session.user.id, async (tx) => {
      const [opportunite] = await tx<LigneOpportunite[]>`
        SELECT o.statut, o.apporteur_id::text, o.moteur_id::text, o.qualifiee_par_id::text,
               EXISTS (
                 SELECT 1
                 FROM positionnement p
                 WHERE p.opportunite_id = o.id
                   AND p.membre_id = ${session.user.id}
                   AND o.mode_candidature = 'contact_direct_recruteur'
                   AND p.etat NOT IN ('ecarte', 'retire')
               ) AS est_positionne
        FROM opportunite o
        WHERE o.id = ${id}
        FOR UPDATE
      `
      if (!opportunite) {
        throw createError({ statusCode: 404, statusMessage: 'Opportunité introuvable' })
      }

      const peutChangerLeStatut = session.role === Role.admin
        || session.user.id === opportunite.apporteur_id
        || session.user.id === opportunite.moteur_id
        || opportunite.est_positionne

      if (!peutChangerLeStatut) {
        throw createError({ statusCode: 403, statusMessage: 'Vous ne pouvez pas modifier le statut de cette opportunité' })
      }

      if (opportunite.statut === donnees.statut) {
        throw createError({ statusCode: 409, statusMessage: 'Cette opportunité possède déjà ce statut' })
      }

      if (donnees.statut === 'matching' && opportunite.qualifiee_par_id === null) {
        throw createError({ statusCode: 409, statusMessage: 'La qualification de l’opportunité doit être validée avant son passage en Matching' })
      }

      await tx`
        UPDATE opportunite
        SET statut = ${donnees.statut},
            raison_perte = ${donnees.statut === 'perdu' ? donnees.raisonPerte ?? null : null},
            date_relance = ${donnees.statut === 'en_pause' ? donnees.dateRelance ?? null : null},
            date_cloture = CASE
              WHEN ${donnees.statut} IN ('signe', 'perdu') THEN CURRENT_DATE
              ELSE NULL
            END
        WHERE id = ${id}
      `

      return { id, statut: libelleStatut(donnees.statut) }
    })
  } catch (error) {
    throw erreurSql(error)
  }
})
