<template>
  <UContainer class="py-6">
    <CarteTitree
      icon="i-lucide-user-search"
      title="Profils extérieurs"
    >
      <div class="flex flex-col gap-4">
        <UInput
          v-model="recherche"
          icon="i-lucide-search"
          placeholder="Recherche"
          class="max-w-xl"
        />

        <div class="flex flex-wrap items-end justify-between gap-3">
          <div class="flex flex-wrap items-end gap-3">
            <ListeDeroulanteLibellee
              v-model="filtres.technologie"
              label="Technologies"
              :items="valeursUniques(p => p.technologies)"
              placeholder="Toutes"
            />
            <UFormField label="Disponibilité">
              <UInput
                v-model="filtres.disponibilite"
                placeholder="Ex. immédiate"
              />
            </UFormField>
            <ListeDeroulanteLibellee
              v-model="filtres.ville"
              label="Ville"
              :items="valeursUniques(p => [p.ville])"
              placeholder="Toutes"
            />
          </div>
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
          :data="profilsFiltres"
          :columns="columns"
        >
          <template #details-cell="{ row }">
            <UButton
              label="Détails"
              trailing-icon="i-lucide-external-link"
              color="neutral"
              variant="outline"
              size="xs"
              :to="`/profils-exterieurs/${row.original.id}`"
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
