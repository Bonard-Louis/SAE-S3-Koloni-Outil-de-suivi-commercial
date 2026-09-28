// Role — les deux profils d'utilisateurs du CRM (recueil de besoins §1.3)
export enum Role {
  admin,
  membre
}

// Utilisateur — compte connecté au CRM
export interface Utilisateur {
  id: string
  nom: string
  prenom: string
  mail: string
  role: Role
}
