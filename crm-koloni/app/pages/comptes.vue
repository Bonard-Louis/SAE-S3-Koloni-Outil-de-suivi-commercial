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
// TODO:
</script>
