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

// Disponibilite — situation d'un membre, visible de tout le collectif
export type Disponibilite = 'en_recherche' | 'en_mission'

// Compte — ligne de la liste d'administration des membres, avec ses compteurs d'activité
export interface Compte {
  id: string
  nom: string
  prenom: string
  mail: string
  telephone?: string
  ville?: string
  role: Role
  disponibilite: Disponibilite
  dateFinMission?: string // AAAA-MM-JJ, uniquement si le membre est en mission
  actif: boolean
  dateCreation: string
  nbOpportunitesApportees: number
  nbOpportunitesMoteur: number
  nbPositionnements: number
  nbMissionsSignees: number
}

// CompteDetail — fiche complète d'un membre, pour le formulaire de modification
export interface CompteDetail {
  id: string
  nom: string
  prenom: string
  mail: string
  telephone?: string
  lienLinkedin?: string
  notes?: string
  role: Role
  ville?: string
  disponibilite: Disponibilite
  dateFinMission?: string
  actif: boolean
}

// CompteursComptes — totaux affichés en tête de la page d'administration
export interface CompteursComptes {
  actifs: number
  desactives: number
  administrateurs: number
  enRecherche: number
  enMission: number
}
