import { Role } from '#shared/types/utilisateur'

export default defineNuxtRouteMiddleware(async (to, _from) => {
  // Redirection désactivée temporairement : /login n'est pas encore développée.
  // TODO(Dresseur_Panda): retirer cette ligne dès que la page de connexion existe.
  return true

  const { isAuthenticated, role, refresh } = useAuth()
  await refresh()

  // Utilisateur non connecté sur /login : on le laisse accéder (évite une boucle infinie)
  if (!isAuthenticated.value && to.path === '/login') return true

  // Non connecté ailleurs que /login : redirection vers la page de connexion
  if (!isAuthenticated.value) return navigateTo('/login', { replace: true })

  // /comptes (gestion des comptes utilisateurs) réservé aux administrateurs
  if (to.path.startsWith('/comptes') && role.value !== Role.admin) {
    return navigateTo('/', { replace: true })
  }
})
