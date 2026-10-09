/**
 * Contrôle d'accès des routes API
 *
 * exigerSession : 401 si personne n'est connecté, ou si son compte est désactivé.
 * exigerAdmin : 403 si l'utilisateur connecté n'est pas administrateur.
 *
 * Le rôle et l'état du compte sont relus en base à chaque appel : un membre désactivé
 * ou rétrogradé perd ses droits tout de suite, sans attendre la fin de sa session.
 */

import type { H3Event } from 'h3'
import { Role } from '#shared/types/utilisateur'

export const exigerSession = async (event: H3Event) => {
  const session = await getUserSession(event)
  if (!session.user) {
    throw createError({ statusCode: 401, statusMessage: 'Authentification requise' })
  }

  const sql = useDb(event)
  const [membre] = await sql<{ role: Role, actif: boolean }[]>`
    SELECT role, actif FROM membre WHERE id = ${session.user.id}
  `
  if (!membre?.actif) {
    await clearUserSession(event)
    throw createError({ statusCode: 401, statusMessage: 'Compte désactivé ou introuvable' })
  }

  return { ...session, user: session.user, role: membre.role }
}

export const exigerAdmin = async (event: H3Event) => {
  const session = await exigerSession(event)
  if (session.role !== Role.admin) {
    throw createError({ statusCode: 403, statusMessage: 'Réservé aux administrateurs' })
  }
  return session
}
