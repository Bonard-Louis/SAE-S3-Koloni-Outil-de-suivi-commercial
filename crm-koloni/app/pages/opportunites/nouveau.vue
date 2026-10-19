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

    <header class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
        Ajouter une opportunité
      </h1>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        Renseignez les informations connues sur le besoin.
      </p>
    </header>

    <UForm :state="form" class="space-y-5" @submit="creer">
      <CarteTitree
        icon="i-lucide-briefcase"
        title="Détails de l'opportunité"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField label="Titre" name="titre" required class="md:col-span-2">
            <UInput v-model="form.titre" placeholder="Ex. Migration de données" class="w-full" />
          </UFormField>
          <UFormField label="Client final" name="clientFinal">
            <UInput v-model="form.clientFinal" placeholder="Nom du client (facultatif)" class="w-full" />
          </UFormField>
          <UFormField label="Ville" name="ville">
            <UInput v-model="form.ville" class="w-full" />
          </UFormField>
          <UFormField label="Mode de travail" name="mode">
            <USelect v-model="form.mode" :items="modes" placeholder="Sélectionner" class="w-full" />
          </UFormField>
          <UFormField label="Température" name="temperature">
            <USelect v-model="form.temperature" :items="temperatures" placeholder="Sélectionner" class="w-full" />
          </UFormField>
          <UFormField label="Technologies (séparées par une virgule)" name="technologies" class="md:col-span-2">
            <UInput v-model="technologies" placeholder="Python, dbt, Snowflake" class="w-full" />
          </UFormField>
          <UFormField label="Date du signal" name="dateSignal" required>
            <UInput v-model="form.dateSignal" type="date" class="w-full" />
          </UFormField>
        </div>
      </CarteTitree>

      <footer class="flex items-center justify-end gap-3 pt-4">
        <UButton to="/opportunites" color="neutral" variant="ghost">
          Annuler
        </UButton>
        <UButton type="submit" :loading="creation" icon="i-lucide-check">
          Créer l'opportunité
        </UButton>
      </footer>
    </UForm>
  </UContainer>
</template>

<script setup lang="ts">
const router = useRouter()
const toast = useToast()

const form = reactive({ titre: '', clientFinal: '', ville: '', mode: '', temperature: '', dateSignal: new Date().toISOString().slice(0, 10) })
const technologies = ref('')
const modes = [{ label: 'Télétravail', value: 'teletravail' }, { label: 'Hybride', value: 'hybride' }, { label: 'Présentiel', value: 'presentiel' }]
const temperatures = [{ label: 'Chaud', value: 'chaud' }, { label: 'Tiède', value: 'tiede' }]
const creation = ref(false)

async function creer() {
  if (!form.titre.trim()) {
    toast.add({ title: 'Le titre est obligatoire.', color: 'error' })
    return
  }

  creation.value = true
  try {
    const resultat = await $fetch<{ id: string }>('/api/opportunites', { method: 'POST', body: { ...form, technologies: technologies.value.split(',').map(t => t.trim()).filter(Boolean) } })
    toast.add({ title: 'Opportunité créée avec succès', color: 'success' })
    await router.push(`/opportunites/${resultat.id}`)
  } catch (error) {
    toast.add({ title: 'Création impossible', description: (error as { data?: { statusMessage?: string } }).data?.statusMessage, color: 'error' })
  } finally {
    creation.value = false
  }
}
</script>
