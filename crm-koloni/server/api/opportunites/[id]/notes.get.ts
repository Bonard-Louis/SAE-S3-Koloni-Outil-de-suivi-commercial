import * as z from 'zod'

export default defineEventHandler(async (event) => {
  await exigerSession(event)
  const { id } = await getValidatedRouterParams(event, z.object({ id: z.string().regex(/^\d+$/) }).parse)
  const sql = useDb(event)

  const notes = await sql<{ id: string, contenu: string, date_redaction: string, auteur: string }[]>`
    SELECT n.id::text, n.contenu,
      to_char(n.date_redaction AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI:SS') AS date_redaction,
      m.prenom || ' ' || m.nom AS auteur
    FROM note n
    JOIN membre m ON m.id = n.auteur_id
    WHERE n.opportunite_id = ${id}
    ORDER BY n.date_redaction DESC, n.id DESC
  `

  return notes.map(note => ({
    id: note.id,
    contenu: note.contenu,
    dateRedaction: note.date_redaction,
    auteur: note.auteur
  }))
})
