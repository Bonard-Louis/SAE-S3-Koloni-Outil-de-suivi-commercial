export default defineEventHandler(async (event) => {
  await exigerSession(event)
  const sql = useDb(event)

  const [membres, entreprises, technologies] = await Promise.all([
    sql<{ id: string, nom: string, prenom: string, mail: string }[]>`
      SELECT id::text, nom, prenom, mail
      FROM membre
      WHERE actif = TRUE
      ORDER BY prenom, nom
    `,
    sql<{ nom: string }[]>`
      SELECT nom FROM entreprise_cliente ORDER BY nom
    `,
    sql<{ nom: string }[]>`
      SELECT nom FROM technologie ORDER BY nom
    `
  ])

  return {
    membres,
    entreprises: entreprises.map(e => e.nom),
    technologies: technologies.map(t => t.nom)
  }
})
