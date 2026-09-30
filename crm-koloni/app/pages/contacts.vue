<template>
  <UContainer class="py-6">
    <CarteTitree
      icon="i-lucide-users"
      title="Contacts"
    >
      <div class="flex flex-col gap-4">
        <UInput
          v-model="recherche"
          icon="i-lucide-search"
          placeholder="Recherche"
          class="max-w-xl"
        />

        <div class="flex flex-wrap items-end justify-between gap-3">
          <ListeDeroulanteLibellee
            v-model="entreprise"
            label="Entreprise"
            :items="entreprises"
            placeholder="Toutes"
          />
          <div class="flex gap-2">
            <UButton
              label="Réinitialiser"
              color="neutral"
              variant="outline"
              @click="reinitialiser"
            />
            <UButton
              label="Valider"
              @click="valider"
            />
          </div>
        </div>

        <UTable
          :data="contactsFiltres"
          :columns="columns"
        >
          <template #details-cell="{ row }">
            <UButton
              label="Détails"
              trailing-icon="i-lucide-external-link"
              color="neutral"
              variant="outline"
              size="xs"
              :to="`/contacts/${row.original.id}`"
            />
          </template>
        </UTable>
      </div>
    </CarteTitree>
  </UContainer>
</template>

<script setup lang="ts">
// TODO:
</script>
