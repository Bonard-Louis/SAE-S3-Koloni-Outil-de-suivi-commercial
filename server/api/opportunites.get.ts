// Liste des opportunités, de la plus récente à la plus ancienne (date du signal)
interface LigneOpportunite {
  id: string
  titre: string
  statut: string
  technologies: string[]
  ville: string | null
  mode: string | null
  client_final: string | null
  apporteur: string
  temperature: string | null
  date_signal: string
}

export default defineEventHandler(async (event) => {
  const sql = useDb(event)

  const lignes = await sql<LigneOpportunite[]>`
    SELECT
      o.id::text,
      o.titre,
      o.statut,
      ARRAY(
        SELECT t.nom
        FROM opportunite_technologie ot
        JOIN technologie t ON t.id = ot.technologie_id
        WHERE ot.opportunite_id = o.id
        ORDER BY ot.est_principale DESC, t.nom
      ) AS technologies,
      o.ville,
      o.mode,
      o.client_final_nom AS client_final,
      m.prenom || ' ' || left(m.nom, 1) || '.' AS apporteur,
      o.temperature,
      to_char(o.date_signal, 'YYYY-MM-DD') AS date_signal
    FROM opportunite o
    JOIN membre m ON m.id = o.apporteur_id
    ORDER BY o.date_signal DESC, o.id DESC
  `

  return lignes.map(l => ({
    id: l.id,
    titre: l.titre,
    statut: libelleStatut(l.statut),
    technologies: l.technologies,
    ville: nullEnUndefined(l.ville),
    mode: libelleMode(l.mode),
    clientFinal: nullEnUndefined(l.client_final),
    apporteur: l.apporteur,
    temperature: libelleTemperature(l.temperature),
    dateSignal: l.date_signal
  }))
})
