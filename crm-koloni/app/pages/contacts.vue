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
import type { TableColumn } from '@nuxt/ui'

// Contact — personne rattachée à une entreprise cliente (cahier des charges §3.3)
interface Contact {
  id: string
  nom: string
  prenom: string
  role?: string // fonction chez le client (colonne « Poste »)
  entreprise?: string // facultative : le contact peut être saisi avant que son entreprise soit connue
  mail?: string
  telephone?: string
}

// Liste alimentée lorsque la base de donnée sera connectée
const contacts = ref<Contact[]>([
  { id: '1', prenom: 'Marc', nom: 'Lefèvre', role: 'Commercial', entreprise: 'Capgemini', mail: 'marc.lefevre@example.com' },
  { id: '2', prenom: 'Sophie', nom: 'Bernard', role: 'Responsable data', entreprise: 'EDF', mail: 'sophie.bernard@example.com', telephone: '06 00 00 00 01' },
  { id: '3', prenom: 'Julien', nom: 'Moreau', role: 'DSI', entreprise: 'Orange', telephone: '06 00 00 00 02' },
  { id: '4', prenom: 'Claire', nom: 'Petit', role: 'Commerciale', entreprise: 'Capgemini', mail: 'claire.petit@example.com' },
  { id: '5', prenom: 'Thomas', nom: 'Roux', mail: 'thomas.roux@example.com' }
])

const columns: TableColumn<Contact>[] = [
  { id: 'nomComplet', header: 'Nom et Prénom', accessorFn: c => `${c.prenom} ${c.nom}` },
  { accessorKey: 'entreprise', header: 'Entreprise' },
  { accessorKey: 'role', header: 'Poste' },
  { id: 'details', header: 'Détails' }
]

const recherche = ref('')
const entreprise = ref<string>()
const entrepriseAppliquee = ref<string>()

const entreprises = computed(() => [...new Set(contacts.value.map(c => c.entreprise).filter(Boolean) as string[])].sort())

// Les filtres ne s'appliquent qu'au clic sur « Valider »
const contactsFiltres = computed(() => {
  const terme = recherche.value.trim().toLowerCase()
  return contacts.value.filter(c =>
    (!terme || [c.nom, c.prenom, c.entreprise, c.role].some(v => v?.toLowerCase().includes(terme)))
    && (!entrepriseAppliquee.value || c.entreprise === entrepriseAppliquee.value)
  )
})

function valider() {
  entrepriseAppliquee.value = entreprise.value
}

function reinitialiser() {
  recherche.value = ''
  entreprise.value = undefined
  valider()
}
</script>
