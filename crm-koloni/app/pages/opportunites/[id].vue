<template>
  <UContainer class="py-8 max-w-3xl">
    <div class="mb-4">
      <UButton
        label="Retour aux opportunités"
        icon="i-lucide-arrow-left"
        color="neutral"
        variant="ghost"
        to="/opportunites"
      />
    </div>

    <template v-if="opportunite">
      <header class="mb-8 flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ opportunite.titre }}
          </h1>
          <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Signalée le {{ formaterDate(opportunite.dateSignal) }}
          </p>
        </div>

        <UBadge
          color="info"
          variant="soft"
        >
          {{ opportunite.statut }}
        </UBadge>
      </header>

      <div class="space-y-5">
        <CarteTitree
          icon="i-lucide-briefcase"
          title="Informations de l'opportunité"
        >
          <dl class="grid grid-cols-1 sm:grid-cols-2 gap-5">
            <div
              v-for="champ in champs"
              :key="champ.label"
            >
              <dt class="text-sm text-gray-500 dark:text-gray-400">
                {{ champ.label }}
              </dt>
              <dd class="font-medium text-gray-900 dark:text-white">
                {{ champ.valeur || champ.defaut }}
              </dd>
            </div>
          </dl>
        </CarteTitree>
      </div>
    </template>

    <UAlert
      v-else
      color="neutral"
      variant="subtle"
      icon="i-lucide-circle-help"
      title="Opportunité introuvable"
    />
  </UContainer>
</template>

<script setup lang="ts">
interface Opportunite {
  id: string
  titre: string
  statut: string
  apporteur: string
  dateSignal?: string // date ISO AAAA-MM-JJ
  clientFinal?: string
  ville?: string
  mode?: string
  temperature?: string
  technologies?: string[]
}

const route = useRoute()

const { data: opportunite } = await useFetch<Opportunite | null>(
  () => `/api/opportunites/${route.params.id}`,
  { default: () => null }
)

function formaterDate(iso?: string) {
  return iso ? iso.split('-').reverse().join('/') : 'date inconnue'
}

const champs = computed(() => {
  const o = opportunite.value
  if (!o) return []
  return [
    { label: 'Client final', valeur: o.clientFinal, defaut: 'Non renseigné' },
    { label: 'Apporteur', valeur: o.apporteur, defaut: 'Non renseigné' },
    { label: 'Ville', valeur: o.ville, defaut: 'Non renseignée' },
    { label: 'Mode', valeur: o.mode, defaut: 'Non renseigné' },
    { label: 'Température', valeur: o.temperature, defaut: 'Non renseignée' },
    { label: 'Technologies', valeur: o.technologies?.join(', '), defaut: 'Non renseignées' }
  ]
})
</script>
