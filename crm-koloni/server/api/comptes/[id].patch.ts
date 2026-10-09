// Modification du rôle et de l'état (actif / désactivé) d'un compte, réservée aux administrateurs.
// Un compte désactivé n'est jamais supprimé : ses traces sont conservées.
import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'

const params = z.object({
  id: z.string().regex(/^\d+$/)
})

const schema = z.object({
  role: z.enum(Role).optional(),
  actif: z.boolean().optional()
}).refine(data => data.role !== undefined || data.actif !== undefined, {
  message: 'Rien à modifier'
})

export default defineEventHandler(async (event) => {
  const session = await exigerAdmin(event)
  const { id } = await getValidatedRouterParams(event, params.parse)
  const { role, actif } = await readValidatedBody(event, schema.parse)

  // Un administrateur ne peut pas modifier son propre compte : il pourrait se retirer ses droits et laisser l'application sans administrateur
  if (id === session.user.id) {
    throw createError({ statusCode: 400, statusMessage: 'Vous ne pouvez pas modifier votre propre compte' })
  }

  const sql = useDb(event)
  const [compte] = await sql<{ id: string, role: Role, actif: boolean }[]>`
    UPDATE membre
    SET role = COALESCE(${role ?? null}, role),
        actif = COALESCE(${actif ?? null}, actif)
    WHERE id = ${id}
    RETURNING id::text, role, actif
  `

  if (!compte) {
    throw createError({ statusCode: 404, statusMessage: 'Compte introuvable' })
  }
  return compte
})
