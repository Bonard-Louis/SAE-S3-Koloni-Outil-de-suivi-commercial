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

        <CarteTitree
          icon="i-lucide-notebook-pen"
          title="Notes"
        >
          <div
            v-if="notes?.length"
            class="space-y-4"
          >
            <article
              v-for="note in notes"
              :key="note.id"
              class="border-b border-gray-200 pb-4 last:border-0 last:pb-0 dark:border-gray-800"
            >
              <p class="whitespace-pre-wrap text-gray-900 dark:text-white">
                {{ note.contenu }}
              </p>
              <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
                {{ note.auteur }} · {{ formaterDateHeure(note.dateRedaction) }}
              </p>
            </article>
          </div>
          <p
            v-else
            class="text-sm text-gray-500 dark:text-gray-400"
          >
            Aucune note pour le moment.
          </p>

          <UForm
            :state="formNote"
            class="mt-6 space-y-3"
            @submit="ajouterNote"
          >
            <UFormField
              label="Ajouter une note"
              name="contenu"
              required
            >
              <UTextarea
                v-model="formNote.contenu"
                :rows="4"
                :maxlength="5000"
                class="w-full"
                placeholder="Partagez une information utile à tous…"
              />
            </UFormField>
            <div class="flex justify-end">
              <UButton
                type="submit"
                icon="i-lucide-send"
                :loading="envoiNote"
                :disabled="!formNote.contenu.trim()"
              >
                Publier la note
              </UButton>
            </div>
          </UForm>
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
const toast = useToast()
const formNote = reactive({ contenu: '' })
const envoiNote = ref(false)

interface NoteOpportunite {
  id: string
  contenu: string
  dateRedaction: string
  auteur: string
}

const { data: opportunite } = await useFetch<Opportunite | null>(
  () => `/api/opportunites/${route.params.id}`,
  { default: () => null }
)
const { data: notes, refresh: rechargerNotes } = await useFetch<NoteOpportunite[]>(
  () => `/api/opportunites/${route.params.id}/notes`,
  { default: () => [] }
)

async function ajouterNote() {
  const contenu = formNote.contenu.trim()
  if (!contenu || envoiNote.value) return

  envoiNote.value = true
  try {
    await $fetch(`/api/opportunites/${route.params.id}/notes`, {
      method: 'POST',
      body: { contenu }
    })
    formNote.contenu = ''
    await rechargerNotes()
    toast.add({ title: 'Note publiée', color: 'success' })
  } catch (error) {
    toast.add({
      title: 'Publication impossible',
      description: (error as { data?: { statusMessage?: string } }).data?.statusMessage,
      color: 'error'
    })
  } finally {
    envoiNote.value = false
  }
}

function formaterDate(iso?: string) {
  return iso ? iso.split('-').reverse().join('/') : 'date inconnue'
}

function formaterDateHeure(iso: string) {
  return new Intl.DateTimeFormat('fr-FR', { dateStyle: 'short', timeStyle: 'short' }).format(new Date(iso))
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
