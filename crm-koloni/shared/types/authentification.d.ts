import type { Role } from './utilisateur'

declare module '#auth-utils' {
  interface User {
    id: string
    nom: string
    prenom: string
    mail: string
  }
  interface UserSession {
    role: Role
  }
}

export {}
