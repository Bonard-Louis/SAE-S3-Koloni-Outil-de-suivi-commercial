<template>
  <UContainer class="py-8 max-w-2xl">
    <div class="mb-4">
      <UButton
        label="Retour aux profils extérieurs"
        icon="i-lucide-arrow-left"
        color="neutral"
        variant="ghost"
        to="/profils-exterieurs"
      />
    </div>

    <header class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
        Ajouter un profil extérieur
      </h1>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        Enregistrez un profil contacté hors collectif sous forme de fiche structurée[cite: 6, 7, 8]
      </p>
    </header>

    <UForm
      :state="form"
      class="space-y-5"
      @submit="creerProfil"
    >
      <CarteTitree
        icon="i-lucide-user-plus"
        title="Identité & Contact"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField
            label="Prénom"
            name="prenom"
            required
          >
            <UInput
              v-model="form.prenom"
              placeholder="Prénom"
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
              placeholder="Nom"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Moyen de contact"
            name="moyenContact"
            class="col-span-full"
          >
            <UInput
              v-model="form.moyenContact"
              placeholder="Mail, téléphone, LinkedIn..."
              class="w-full"
            />
          </UFormField>
        </section>
      </CarteTitree>

      <CarteTitree
        icon="i-lucide-code"
        title="Compétences & Expériences"
      >
        <section class="space-y-4">
          <UFormField
            label="Technologies (séparées par une virgule)"
            name="technologies"
          >
            <UInput
              v-model="technologiesInput"
              placeholder="Ex. Python, dbt, Snowflake"
              class="w-full"
            />
          </UFormField>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <UFormField
              label="Niveau d'expérience"
              name="niveau"
            >
              <USelect
                v-model="form.niveau"
                :items="['Opérationnel', 'Senior', 'Expert']"
                placeholder="Sélectionner le niveau"
                class="w-full"
              />
            </UFormField>

            <UFormField
              label="TJM souhaité (€)"
              name="tjm"
            >
              <UInput
                v-model="form.tjm"
                type="number"
                placeholder="Ex. 500"
                class="w-full"
              />
            </UFormField>
          </div>

          <UFormField
            label="Expériences clés"
            name="experiencesCles"
          >
            <UTextarea
              v-model="form.experiencesCles"
              :rows="3"
              placeholder="Résumé des expériences..."
              class="w-full"
            />
          </UFormField>
        </section>
      </CarteTitree>

      <CarteTitree
        icon="i-lucide-calendar"
        title="Disponibilité & Sollicitation"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField
            label="Ville"
            name="ville"
          >
            <UInput
              v-model="form.ville"
              placeholder="Ex. Toulouse, Paris..."
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Disponibilité"
            name="disponibilite"
          >
            <UInput
              v-model="form.disponibilite"
              placeholder="Immédiate, À partir du..."
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Date de sollicitation"
            name="dateSollicitation"
            required
          >
            <UInput
              v-model="form.dateSollicitation"
              type="date"
              class="w-full"
            />
          </UFormField>

          <UFormField
            label="Issue de la sollicitation"
            name="issue"
          >
            <USelect
              v-model="form.issue"
              :items="ISSUES"
              placeholder="Sélectionner l'issue"
              class="w-full"
            />
          </UFormField>
        </section>
      </CarteTitree>

      <footer class="flex items-center justify-end gap-3 pt-4">
        <UButton
          to="/profils-exterieurs"
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
          Enregistrer le profil
        </UButton>
      </footer>
    </UForm>
  </UContainer>
</template>

<script setup lang="ts">
const router = useRouter()
const toast = useToast()

const ISSUES = [
  'Présenté',
  'Retenu',
  'Écarté par le client',
  'Indisponible',
  'Sans réponse du profil',
  'Sans retour du client'
]

const form = reactive({
  prenom: '',
  nom: '',
  moyenContact: '',
  niveau: undefined as string | undefined,
  experiencesCles: '',
  ville: '',
  disponibilite: '',
  tjm: undefined as number | undefined,
  dateSollicitation: new Date().toISOString().split('T')[0],
  issue: undefined as string | undefined
})

const technologiesInput = ref('')
const creation = ref(false)

async function creerProfil() {
  if (!form.prenom.trim() || !form.nom.trim()) {
    toast.add({ title: 'Le prénom et le nom sont obligatoires.', color: 'error' })
    return
  }

  creation.value = true
  try {
    const technologies = technologiesInput.value
      .split(',')
      .map(t => t.trim())
      .filter(Boolean)

    const payload = {
      ...form,
      technologies
    }

    toast.add({ title: 'Profil extérieur enregistré avec succès', color: 'success' })
    router.push('/profils-exterieurs')
  } catch {
    toast.add({ title: 'Erreur lors de l’enregistrement', color: 'error' })
  } finally {
    creation.value = false
  }
}
</script>
