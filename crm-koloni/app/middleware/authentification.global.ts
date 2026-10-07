import { Role } from '#shared/types/utilisateur'

export default defineNuxtRouteMiddleware((to) => {
  const { isAuthenticated, role } = useAuth()

  // Page de connexion : un utilisateur déjà connecté est renvoyé à l'accueil
  if (to.path === '/connexion/login') {
    return isAuthenticated.value ? navigateTo('/', { replace: true }) : true
  }

  // Toute autre page exige d'être connecté
  if (!isAuthenticated.value) return navigateTo('/connexion/login', { replace: true })

  // Gestion des comptes et création de compte réservées aux administrateurs
  const reserveAdmin = to.path.startsWith('/comptes') || to.path === '/connexion/register'
  if (reserveAdmin && role.value !== Role.admin) {
    return navigateTo('/', { replace: true })
  }
})
