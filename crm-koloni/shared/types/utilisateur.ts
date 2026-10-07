// Role — les deux profils d'utilisateurs du CRM (recueil de besoins §1.3)
// Les valeurs sont celles stockées dans membre.role.
export enum Role {
  admin = 'administrateur',
  membre = 'membre'
}

// Utilisateur — compte connecté au CRM
export interface Utilisateur {
  id: string
  nom: string
  prenom: string
  mail: string
  role: Role
}
