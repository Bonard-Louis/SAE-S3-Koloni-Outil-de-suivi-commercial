// Liste des contacts côté client, par ordre alphabétique
interface LigneContact {
  id: string
  nom: string
  prenom: string
  role: string | null
  entreprise: string | null
  mail: string | null
  telephone: string | null
}

export default defineEventHandler(async (event) => {
  const sql = useDb(event)

  const lignes = await sql<LigneContact[]>`
    SELECT c.id::text, c.nom, c.prenom, c.role, e.nom AS entreprise, c.mail, c.telephone
    FROM contact c
    LEFT JOIN entreprise_cliente e ON e.id = c.entreprise_cliente_id
    ORDER BY c.nom, c.prenom
  `

  return lignes.map(l => ({
    id: l.id,
    nom: l.nom,
    prenom: l.prenom,
    role: nullEnUndefined(l.role),
    entreprise: nullEnUndefined(l.entreprise),
    mail: nullEnUndefined(l.mail),
    telephone: nullEnUndefined(l.telephone)
  }))
})
