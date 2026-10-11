// Liste des profils extérieurs, du plus récemment sollicité au plus ancien
// La date est celle de la dernière sollicitation du profil ; un profil jamais sollicité arrive en fin de liste, sans date.
interface LigneProfil {
  id: string
  nom: string
  prenom: string
  technologies: string[]
  ville: string | null
  disponibilite: string | null
  date_sollicitation: string | null
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
      to_char(s.date_sollicitation, 'YYYY-MM-DD') AS date_sollicitation
    FROM profil_exterieur p
    LEFT JOIN profil_exterieur_derniere_sollicitation s ON s.profil_exterieur_id = p.id
    ORDER BY s.date_sollicitation DESC NULLS LAST, p.id DESC
  `

  return lignes.map(l => ({
    id: l.id,
    nom: l.nom,
    prenom: l.prenom,
    technologies: l.technologies,
    ville: nullEnUndefined(l.ville),
    disponibilite: nullEnUndefined(l.disponibilite),
    dateSollicitation: nullEnUndefined(l.date_sollicitation)
  }))
})
