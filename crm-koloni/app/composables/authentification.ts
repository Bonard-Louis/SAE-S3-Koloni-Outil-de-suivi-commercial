/**
 * Composable d'authentification
 *
 * Fournit l'état d'authentification, le rôle de l'utilisateur connecté
 * et l'accès à sa session, à partir de nuxt-auth-utils.
 */

import { Role } from '#shared/types/utilisateur'

export const useAuth = () => {
  const { user, loggedIn, session, clear, fetch } = useUserSession()

  const isAuthenticated = computed(() => loggedIn.value)
  const role = computed(() => (session.value?.role as Role) ?? Role.membre)
  const isAdmin = computed(() => role.value === Role.admin)

  return {
    isAuthenticated,
    user: readonly(user),
    role,
    isAdmin,
    session: readonly(session),

    refresh: fetch,
    logout: clear
  }
}
