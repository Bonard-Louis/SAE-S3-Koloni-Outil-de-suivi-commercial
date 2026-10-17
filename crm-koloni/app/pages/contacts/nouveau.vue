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
        Ajouter un contact
      </h1>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        Renseignez les informations du nouveau contact client
      </p>
    </header>

    <UForm
      :state="form"
      class="space-y-5"
      @submit="creerContact"
    >
      <CarteTitree
        icon="i-lucide-user-plus"
        title="Informations du contact"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField label="Prénom" name="prenom" required>
            <UInput v-model="form.prenom" placeholder="Prénom" class="w-full" />
          </UFormField>

          <UFormField label="Nom" name="nom" required>
            <UInput v-model="form.nom" placeholder="Nom" class="w-full" />
          </UFormField>

          <UFormField label="Poste / Fonction" name="role">
            <UInput v-model="form.role" placeholder="Ex. DSI, Commercial..." class="w-full" />
          </UFormField>

          <UFormField label="Entreprise cliente" name="entreprise">
            <USelect
              v-model="form.entreprise"
              :items="entreprisesDisponibles"
              placeholder="Sélectionner une entreprise"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Adresse email" name="mail">
            <UInput v-model="form.mail" type="email" placeholder="nom@entreprise.fr" class="w-full" />
          </UFormField>

          <UFormField label="Téléphone" name="telephone">
            <UInput v-model="form.telephone" placeholder="06 00 00 00 00" class="w-full" />
          </UFormField>
        </section>
      </CarteTitree>

      <footer class="flex items-center justify-end gap-3 pt-4">
        <UButton
          to="/contacts"
          variant="ghost"
          color="neutral"
        >
          Annuler
        </UButton>
        <UButton
          type="submit"
          :loading="creation"
          icon="i-lucide-check"
        >
          Créer le contact
        </UButton>
      </footer>
    </UForm>
  </UContainer>
</template>

<script setup lang="ts">
const router = useRouter()
const toast = useToast()

const entreprisesDisponibles = ['Capgemini', 'EDF', 'Orange', 'SNCF', 'Airbus']

const form = reactive({
  prenom: '',
  nom: '',
  role: '',
  entreprise: undefined as string | undefined,
  mail: '',
  telephone: ''
})

const creation = ref(false)

async function creerContact() {
  if (!form.prenom.trim() || !form.nom.trim()) {
    toast.add({ title: 'Le prénom et le nom sont obligatoires.', color: 'error' })
    return
  }

  creation.value = true
  try {
    toast.add({ title: 'Contact créé avec succès', color: 'success' })
    router.push('/contacts')
  } catch {
    toast.add({ title: 'Erreur lors de la création', color: 'error' })
  } finally {
    creation.value = false
  }
}
</script>