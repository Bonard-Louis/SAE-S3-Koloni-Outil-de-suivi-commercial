/**
 * Accès à la base PostgreSQL
 *
 * Le pool de connexions est créé au premier appel, puis réutilisé par toutes les routes.
 * Les paramètres viennent de runtimeConfig.database (variables NUXT_DATABASE_*).
 */

import type { H3Event } from 'h3'
import postgres from 'postgres'

let sql: postgres.Sql | undefined

export const useDb = (event: H3Event) => {
  if (!sql) {
    const { host, port, name, user, password } = useRuntimeConfig(event).database
    sql = postgres({
      host,
      port: Number(port),
      database: name,
      username: user,
      password,
      max: 10,
      idle_timeout: 30,
      connect_timeout: 10
    })
  }
  return sql
}
