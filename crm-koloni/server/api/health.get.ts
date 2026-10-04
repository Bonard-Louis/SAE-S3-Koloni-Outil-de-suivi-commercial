// Vérifie que le serveur Nuxt joint la base de données
export default defineEventHandler(async (event) => {
  const sql = useDb(event)

  try {
    const [ligne] = await sql<{ version: string }[]>`SELECT version()`
    return { status: 'ok', database: ligne?.version }
  } catch (error) {
    console.error('Connexion à la base impossible :', error)
    throw createError({ statusCode: 503, statusMessage: 'Base de données injoignable' })
  }
})
