<template>
  <UContainer class="py-8 max-w-2xl">
    <div class="mb-4">
      <UButton
        label="Retour aux contacts"
        icon="i-lucide-arrow-left"
        color="neutral"
        variant="ghost"
        to="/contacts"
      />
    </div>

    <header class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
        Détail du contact
      </h1>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        {{ contact ? `${contact.prenom} ${contact.nom}` : 'Chargement...' }}
      </p>
    </header>

    <UForm
      v-if="contact"
      :state="form"
      class="space-y-5"
      @submit="enregistrer"
    >
      <CarteTitree
        icon="i-lucide-user"
        title="Informations générales"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField
            label="Prénom"
            name="prenom"
            required
          >
            <UInput
              v-model="form.prenom"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Nom"
            name="nom"
            required
          >
            <UInput
              v-model="form.nom"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Poste / Fonction"
            name="role"
          >
            <UInput
              v-model="form.role"
              placeholder="Ex. Commercial"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Entreprise"
            name="entreprise"
          >
            <USelect
              v-model="form.entreprise"
              :items="entreprisesDisponibles"
              placeholder="Sélectionner une entreprise"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Adresse email"
            name="mail"
          >
            <UInput
              v-model="form.mail"
              type="email"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Téléphone"
            name="telephone"
          >
            <UInput
              v-model="form.telephone"
              class="w-full"
            />
          </UFormField>
        </section>
      </CarteTitree>

      <footer class="flex items-center justify-end gap-3 pt-4">
        <UButton
          type="submit"
          :loading="enregistrement"
          icon="i-lucide-save"
        >
          Enregistrer les modifications
        </UButton>
      </footer>
    </UForm>

    <div
      v-else
      class="text-gray-500 dark:text-gray-400 py-4"
    >
      Contact introuvable.
    </div>
  </UContainer>
</template>

<script setup lang="ts">
const route = useRoute()
const toast = useToast()

interface Contact {
  id: string
  nom: string
  prenom: string
  role?: string
  entreprise?: string
  mail?: string
  telephone?: string
}

const contacts = ref<Contact[]>([
  { id: '1', prenom: 'Marc', nom: 'Lefèvre', role: 'Commercial', entreprise: 'Capgemini', mail: 'marc.lefevre@example.com' },
  { id: '2', prenom: 'Sophie', nom: 'Bernard', role: 'Responsable data', entreprise: 'EDF', mail: 'sophie.bernard@example.com', telephone: '06 00 00 00 01' }
])

const entreprisesDisponibles = ['Capgemini', 'EDF', 'Orange', 'SNCF', 'Airbus']

const contact = computed(() => contacts.value.find(c => c.id === route.params.id))

const form = reactive({
  prenom: '',
  nom: '',
  role: '',
  entreprise: undefined as string | undefined,
  mail: '',
  telephone: ''
})

watch(contact, (val) => {
  if (val) {
    form.prenom = val.prenom
    form.nom = val.nom
    form.role = val.role ?? ''
    form.entreprise = val.entreprise
    form.mail = val.mail ?? ''
    form.telephone = val.telephone ?? ''
  }
}, { immediate: true })

const enregistrement = ref(false)

async function enregistrer() {
  if (!form.prenom.trim() || !form.nom.trim()) {
    toast.add({ title: 'Le prénom et le nom sont obligatoires.', color: 'error' })
    return
  }
  enregistrement.value = true
  try {
    toast.add({ title: 'Contact mis à jour avec succès', color: 'success' })
  } catch {
    toast.add({ title: 'Erreur lors de la mise à jour', color: 'error' })
  } finally {
    enregistrement.value = false
  }
}
</script>
