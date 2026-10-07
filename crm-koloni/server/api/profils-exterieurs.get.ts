// Liste des profils extérieurs, du plus récemment sollicité au plus ancien
interface LigneProfil {
  id: string
  nom: string
  prenom: string
  technologies: string[]
  ville: string | null
  disponibilite: string | null
  date_sollicitation: string
}

export default defineEventHandler(async (event) => {
  await exigerSession(event)
  const sql = useDb(event)

  const lignes = await sql<LigneProfil[]>`
    SELECT
      p.id::text,
      p.nom,
      p.prenom,
      ARRAY(
        SELECT t.nom
        FROM profil_exterieur_technologie pt
        JOIN technologie t ON t.id = pt.technologie_id
        WHERE pt.profil_exterieur_id = p.id
        ORDER BY t.nom
      ) AS technologies,
      p.ville,
      p.disponibilite,
      to_char(p.date_sollicitation, 'YYYY-MM-DD') AS date_sollicitation
    FROM profil_exterieur p
    ORDER BY p.date_sollicitation DESC, p.id DESC
  `

  return lignes.map(l => ({
    id: l.id,
    nom: l.nom,
    prenom: l.prenom,
    technologies: l.technologies,
    ville: nullEnUndefined(l.ville),
    disponibilite: nullEnUndefined(l.disponibilite),
    dateSollicitation: l.date_sollicitation
  }))
})
