<template>
  <div class="text-sm font-medium">
    {{ nomComplet }} <span class="text-muted">({{ libelleRole }})</span>
  </div>
</template>

<script lang="ts" setup>
import { Role } from '#shared/types/utilisateur'

const { user, role } = useAuth()

const nomComplet = computed(() => user.value ? `${user.value.prenom} ${user.value.nom}` : 'Utilisateur inconnu')

const libelleRole = computed(() => role.value === Role.admin ? 'Administrateur' : 'Membre')
</script>
