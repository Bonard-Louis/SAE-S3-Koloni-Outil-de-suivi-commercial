/**
 * Règles de validation d'un membre, communes à la création et à la modification
 *
 * Un champ facultatif vide ("" ou espaces) est enregistré comme absent (NULL).
 * Ces règles reprennent celles de la table membre : la base reste la dernière barrière.
 */

import * as z from 'zod'
import { Role } from '#shared/types/utilisateur'
import type { Disponibilite } from '#shared/types/utilisateur'

// "" et espaces -> null, pour qu'un champ vidé dans un formulaire efface la valeur en base
const videEnNull = (valeur: unknown) =>
  typeof valeur === 'string' && valeur.trim() === '' ? null : valeur

const facultatif = <T extends z.ZodType>(schema: T) => z.preprocess(videEnNull, schema.nullable())

export const champsMembre = {
  nom: z.string().trim().min(1).max(100),
  prenom: z.string().trim().min(1).max(100),
  mail: z.email().max(255).transform(mail => mail.toLowerCase()),
  telephone: facultatif(z.string().trim().max(30)),
  lien_linkedin: facultatif(z.string().trim().max(255).regex(/^https:\/\/([\w-]+\.)*linkedin\.com\/\S*$/i, 'Lien LinkedIn invalide')),
  notes: facultatif(z.string().trim().max(5000)),
  role: z.enum(Role),
  ville: facultatif(z.string().trim().max(100)),
  disponibilite: z.enum(['en_recherche', 'en_mission']),
  date_fin_mission: facultatif(z.iso.date())
}

export const motDePasse = z.string().min(8).max(200)

// La date de fin de mission n'a de sens que pour un membre en mission (chk_membre_date_fin_mission)
export const dateFinMissionAutorisee = (disponibilite: Disponibilite, date: string | null | undefined) =>
  disponibilite === 'en_mission' ? (date ?? null) : null
