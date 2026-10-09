// Liste des comptes membres, réservée aux administrateurs (EF-02)
import type { Role } from '#shared/types/utilisateur'

interface LigneCompte {
  id: string
  nom: string
  prenom: string
  mail: string
  role: Role
  actif: boolean
}

export default defineEventHandler(async (event) => {
  await exigerAdmin(event)
  const sql = useDb(event)

  return await sql<LigneCompte[]>`
    SELECT id::text, nom, prenom, mail, role, actif
    FROM membre
    ORDER BY nom, prenom
  `
})
