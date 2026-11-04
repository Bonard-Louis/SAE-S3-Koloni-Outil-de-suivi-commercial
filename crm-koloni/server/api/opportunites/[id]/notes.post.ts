import * as z from 'zod'

const schema = z.object({
  contenu: z.string().trim().min(1, 'La note ne peut pas être vide.').max(5000)
})

export default defineEventHandler(async (event) => {
  const session = await exigerSession(event)
  const { id } = await getValidatedRouterParams(event, z.object({ id: z.string().regex(/^\d+$/) }).parse)
  const { contenu } = await readValidatedBody(event, schema.parse)
  const sql = useDb(event)

  const [note] = await sql<{ id: string }[]>`
    INSERT INTO note (opportunite_id, auteur_id, contenu)
    SELECT o.id, m.id, ${contenu}
    FROM opportunite o
    JOIN membre m ON m.id = ${session.user.id} AND m.actif = TRUE
    WHERE o.id = ${id}
    RETURNING id::text
  `

  if (!note) {
    throw createError({ statusCode: 404, statusMessage: 'Opportunité introuvable' })
  }

  setResponseStatus(event, 201)
  return { id: note.id }
})
