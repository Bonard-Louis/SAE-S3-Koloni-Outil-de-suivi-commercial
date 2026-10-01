<template>
  <UContainer class="py-6">
    <CarteTitree
      icon="i-lucide-shield"
      title="Paramètres du compte : Nicolas D."
    >
      <div class="flex max-w-xl flex-col gap-6">
        <URadioGroup
          v-model="role"
          legend="Rôle"
          :items="rolesDisponibles"
        />
        <URadioGroup
          v-model="actif"
          legend="État du compte"
          :items="etatsDisponibles"
        />
      </div>
    </CarteTitree>
  </UContainer>
</template>

<script setup lang="ts">
import { Role } from '#shared/types/utilisateur'

const rolesDisponibles = [
  { label: 'Administrateur', value: Role.admin },
  { label: 'Membre', value: Role.membre }
]

const etatsDisponibles = [
  { label: 'Activer', value: true },
  { label: 'Désactiver', value: false }
]

const role = ref<Role>(Role.membre)
// Désactiver un compte ne supprime jamais la ligne : les traces du membre sont conservées
const actif = ref(true)
</script>
