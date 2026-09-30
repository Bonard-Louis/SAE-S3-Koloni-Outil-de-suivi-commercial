<template>
  <UContainer class="py-6">
    <CarteTitree
      icon="i-lucide-briefcase"
      title="Opportunités"
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
              v-for="filtre in FILTRES"
              :key="filtre.cle"
              v-model="filtres[filtre.cle]"
              :label="filtre.label"
              :items="valeursUniques(filtre.valeurs)"
              placeholder="Tous"
            />
            <UFormField label="Date du signal">
              <UInput
                v-model="filtres.dateSignal"
                type="date"
              />
            </UFormField>
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

        <TableauOpportunites
          :opportunites="opportunitesPage"
          :get-badges="getOpportuniteBadges"
        />

        <BarrePagination
          v-model:page="page"
          :total="opportunitesFiltrees.length"
          :items-per-page="ITEMS_PAR_PAGE"
        />
      </div>
    </CarteTitree>
  </UContainer>
</template>

<script setup lang="ts">
// TODO:
</script>
