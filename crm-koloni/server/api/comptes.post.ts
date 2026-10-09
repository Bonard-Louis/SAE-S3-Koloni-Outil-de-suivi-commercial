// Création d'un compte membre, réservée aux administrateurs (EF-02)
import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'

const schema = z.object({
  prenom: z.string().trim().min(1).max(100),
  nom: z.string().trim().min(1).max(100),
  mail: z.email().max(255).transform(mail => mail.toLowerCase()),
  password: z.string().min(8).max(200),
  role: z.enum(Role).default(Role.membre)
})

export default defineEventHandler(async (event) => {
  await exigerAdmin(event)
  const { prenom, nom, mail, password, role } = await readValidatedBody(event, schema.parse)
  const sql = useDb(event)

  const hash = await hashPassword(password)

  try {
    const [membre] = await sql<{ id: string }[]>`
      INSERT INTO membre (prenom, nom, mail, role, mot_de_passe_hash)
      VALUES (${prenom}, ${nom}, ${mail}, ${role}, ${hash})
      RETURNING id::text
    `
    setResponseStatus(event, 201)
    return { id: membre!.id }
  } catch (error) {
    throw erreurSql(error)
  }
})
