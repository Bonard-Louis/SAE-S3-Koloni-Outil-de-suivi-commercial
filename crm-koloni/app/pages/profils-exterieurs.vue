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
import type { TableColumn } from '@nuxt/ui'

// ProfilExterieur — profil contacté hors collectif, fiche technique structurée (cahier des charges §3.3)
interface ProfilExterieur {
  id: string
  nom: string
  prenom: string
  technologies: string[]
  ville?: string
  disponibilite?: string // texte libre : « Immédiate », « À partir du … »
  dateSollicitation: string // date ISO AAAA-MM-JJ
}

interface Filtres {
  technologie?: string
  disponibilite?: string
  ville?: string
}

// Liste alimentée lorsque la base de donnée sera connectée
const profils = ref<ProfilExterieur[]>([
  { id: '1', prenom: 'Léa', nom: 'Martin', technologies: ['Python', 'dbt'], ville: 'Paris', disponibilite: 'Immédiate', dateSollicitation: '2026-09-25' },
  { id: '2', prenom: 'Hugo', nom: 'Girard', technologies: ['Power BI'], ville: 'Lyon', disponibilite: 'À partir du 15/10/2026', dateSollicitation: '2026-09-18' },
  { id: '3', prenom: 'Inès', nom: 'Faure', technologies: ['Talend', 'Snowflake'], ville: 'Toulouse', disponibilite: 'Immédiate', dateSollicitation: '2026-09-10' },
  { id: '4', prenom: 'Nathan', nom: 'Blanc', technologies: ['Kafka', 'Python'], disponibilite: 'À partir du 01/11/2026', dateSollicitation: '2026-08-29' }
])

const columns = computed<TableColumn<ProfilExterieur>[]>(() => [
  { id: 'nomComplet', header: 'Nom et Prénom', accessorFn: p => `${p.prenom} ${p.nom}` },
  { id: 'technologies', header: 'Technologies', accessorFn: p => p.technologies.join(', ') },
  { accessorKey: 'disponibilite', header: 'Disponibilité' },
  { accessorKey: 'ville', header: 'Ville' },
  {
    id: 'dateSollicitation',
    header: 'Date de sollicitation',
    accessorFn: p => p.dateSollicitation.split('-').reverse().join('/')
  },
  { id: 'details', header: 'Détails' }
])

const recherche = ref('')
const filtres = reactive<Filtres>({})
const filtresAppliques = ref<Filtres>({})

function valeursUniques(get: (p: ProfilExterieur) => (string | undefined)[]) {
  return [...new Set(profils.value.flatMap(get).filter(Boolean) as string[])].sort()
}

// Les filtres ne s'appliquent qu'au clic sur « Valider »
const profilsFiltres = computed(() => {
  const terme = recherche.value.trim().toLowerCase()
  const { technologie, disponibilite, ville } = filtresAppliques.value
  return profils.value.filter(p =>
    (!terme || [p.nom, p.prenom, ...p.technologies].some(v => v.toLowerCase().includes(terme)))
    && (!technologie || p.technologies.includes(technologie))
    && (!disponibilite || p.disponibilite?.toLowerCase().includes(disponibilite.trim().toLowerCase()))
    && (!ville || p.ville === ville)
  )
})

function valider() {
  filtresAppliques.value = { ...filtres }
}

function reinitialiser() {
  recherche.value = ''
  Object.assign(filtres, { technologie: undefined, disponibilite: undefined, ville: undefined })
  valider()
}
</script>
