import * as z from 'zod'

export default defineEventHandler(async (event) => {
  await exigerSession(event)
  const { id } = await getValidatedRouterParams(event, z.object({ id: z.string().regex(/^\d+$/) }).parse)
  const sql = useDb(event)
  const [l] = await sql<{ id: string, titre: string, statut: string, technologies: string[], ville: string | null, mode: string | null, client_final: string | null, apporteur: string, temperature: string | null, date_signal: string }[]>`
    SELECT o.id::text, o.titre, o.statut,
      ARRAY(SELECT t.nom FROM opportunite_technologie ot JOIN technologie t ON t.id = ot.technologie_id WHERE ot.opportunite_id = o.id ORDER BY ot.est_principale DESC, t.nom) AS technologies,
      o.ville, o.mode, ec.nom AS client_final,
      m.prenom || ' ' || left(m.nom, 1) || '.' AS apporteur, o.temperature,
      to_char(o.date_signal, 'YYYY-MM-DD') AS date_signal
    FROM opportunite o JOIN membre m ON m.id = o.apporteur_id
    LEFT JOIN entreprise_cliente ec ON ec.id = o.client_final_id WHERE o.id = ${id}
  `
  if (!l) throw createError({ statusCode: 404, statusMessage: 'Opportunité introuvable' })
  return { id: l.id, titre: l.titre, statut: libelleStatut(l.statut), technologies: l.technologies, ville: nullEnUndefined(l.ville), mode: libelleMode(l.mode), clientFinal: nullEnUndefined(l.client_final), apporteur: l.apporteur, temperature: libelleTemperature(l.temperature), dateSignal: l.date_signal }
})
