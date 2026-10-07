/**
 * Contrôle d'accès des routes API
 *
 * exigerSession : 401 si personne n'est connecté.
 * exigerAdmin : 403 si l'utilisateur connecté n'est pas administrateur.
 */

import type { H3Event } from 'h3'
import { Role } from '#shared/types/utilisateur'

export const exigerSession = async (event: H3Event) => {
  const session = await getUserSession(event)
  if (!session.user) {
    throw createError({ statusCode: 401, statusMessage: 'Authentification requise' })
  }
  return { ...session, user: session.user, role: session.role as Role }
}

export const exigerAdmin = async (event: H3Event) => {
  const session = await exigerSession(event)
  if (session.role !== Role.admin) {
    throw createError({ statusCode: 403, statusMessage: 'Réservé aux administrateurs' })
  }
  return session
}
