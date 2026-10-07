// Déconnexion : supprime la session
export default defineEventHandler(async (event) => {
  await clearUserSession(event)
  return { ok: true }
})
