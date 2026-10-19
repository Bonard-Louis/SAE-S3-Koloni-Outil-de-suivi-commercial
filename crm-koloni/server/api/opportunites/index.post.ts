import * as z from 'zod'

const schema = z.object({
  titre: z.string().trim().min(1).max(255),
  clientFinal: z.string().trim().max(255).optional(),
  ville: z.string().trim().max(100).optional(),
  mode: z.enum(['teletravail', 'hybride', 'presentiel']).optional().or(z.literal('')),
  temperature: z.enum(['chaud', 'tiede']).optional().or(z.literal('')),
  dateSignal: z.iso.date(),
  technologies: z.array(z.string().trim().min(1).max(100)).max(30).default([])
})

export default defineEventHandler(async (event) => {
  const session = await exigerSession(event)
  const body = await readValidatedBody(event, schema.parse)
  const sql = useDb(event)
  let clientId: string | null = null
  if (body.clientFinal) {
    const [client] = await sql<{ id: string }[]>`
      INSERT INTO entreprise_cliente (nom) VALUES (${body.clientFinal})
      ON CONFLICT (lower(btrim(nom))) DO UPDATE SET nom = entreprise_cliente.nom
      RETURNING id::text
    `
    clientId = client!.id
  }
  const [opportunite] = await sql<{ id: string }[]>`
    INSERT INTO opportunite (titre, statut, client_final_id, apporteur_id, saisi_par_id, ville, mode, temperature, date_signal)
    VALUES (${body.titre}, 'signal', ${clientId}, ${session.user.id}, ${session.user.id}, ${body.ville || null}, ${body.mode || null}, ${body.temperature || null}, ${body.dateSignal})
    RETURNING id::text
  `
  for (const nom of [...new Set(body.technologies)]) {
    const [tech] = await sql<{ id: string }[]>`
      INSERT INTO technologie (nom) VALUES (${nom})
      ON CONFLICT (lower(btrim(nom))) DO UPDATE SET nom = technologie.nom
      RETURNING id::text
    `
    await sql`INSERT INTO opportunite_technologie (opportunite_id, technologie_id) VALUES (${opportunite!.id}, ${tech!.id}) ON CONFLICT DO NOTHING`
  }
  setResponseStatus(event, 201)
  return { id: opportunite!.id }
})
