// Création d'un compte membre, réservée aux administrateurs (EF-02)
// L'administrateur choisit le mot de passe initial. La création d'un compte n'est pas journalisée :
// le journal ne trace que les actions menées sur une opportunité.
import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'

const schema = z.object({
  nom: champsMembre.nom,
  prenom: champsMembre.prenom,
  mail: champsMembre.mail,
  password: motDePasse,
  telephone: champsMembre.telephone.optional(),
  lien_linkedin: champsMembre.lien_linkedin.optional(),
  notes: champsMembre.notes.optional(),
  role: champsMembre.role.default(Role.membre),
  ville: champsMembre.ville.optional(),
  disponibilite: champsMembre.disponibilite.default('en_recherche'),
  date_fin_mission: champsMembre.date_fin_mission.optional()
})

export default defineEventHandler(async (event) => {
  await exigerAdmin(event)
  const corps = await readValidatedBody(event, schema.parse)
  const sql = useDb(event)

  const hash = await hashPassword(corps.password)
  const dateFinMission = dateFinMissionAutorisee(corps.disponibilite, corps.date_fin_mission)

  try {
    const [membre] = await sql<{ id: string }[]>`
      INSERT INTO membre (nom, prenom, mail, telephone, lien_linkedin, notes, role, ville,
                          disponibilite, date_fin_mission, mot_de_passe_hash)
      VALUES (${corps.nom}, ${corps.prenom}, ${corps.mail}, ${corps.telephone ?? null},
              ${corps.lien_linkedin ?? null}, ${corps.notes ?? null}, ${corps.role}, ${corps.ville ?? null},
              ${corps.disponibilite}, ${dateFinMission}::date, ${hash})
      RETURNING id::text
    `
    setResponseStatus(event, 201)
    return { id: membre!.id }
  } catch (error) {
    throw erreurSql(error)
  }
})
