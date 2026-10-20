<template>
  <UContainer class="py-8 max-w-4xl">
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
        Renseignez le besoin, les conditions de la mission et les modalités de candidature.
      </p>
    </header>

    <UAlert
      v-if="erreurOptions"
      color="error"
      variant="subtle"
      icon="i-lucide-circle-alert"
      title="Impossible de charger les listes de choix"
      description="Vérifiez la connexion à la base de données et rechargez la page."
      class="mb-5"
    />

    <UForm
      :state="form"
      class="space-y-5"
      @submit="creer"
    >
      <CarteTitree
        icon="i-lucide-briefcase"
        title="Source et besoin"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField label="Titre" name="titre" required class="md:col-span-2">
            <UInput
              v-model="form.titre"
              placeholder="Ex. Migration de données"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Source du besoin" name="source">
            <USelect
              v-model="form.source"
              :items="sources"
              placeholder="Sélectionner une source"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Type de mission" name="typeMission">
            <UInputMenu
              v-model="form.typeMission"
              :items="typesMission"
              create-item="always"
              placeholder="Choisir ou saisir un type"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Niveau recherché" name="niveauRecherche">
            <USelect
              v-model="form.niveauRecherche"
              :items="niveaux"
              placeholder="Sélectionner un niveau"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Client final" name="clientFinal">
            <UInputMenu
              v-model="form.clientFinal"
              :items="entreprises"
              create-item="always"
              placeholder="Rechercher ou saisir une entreprise"
              class="w-full"
            />
          </UFormField>

          <template v-if="!form.clientFinal">
            <UFormField label="Secteur du client" name="clientFinalSecteur">
              <UInput v-model="form.clientFinalSecteur" placeholder="Ex. Banque, industrie" class="w-full" />
            </UFormField>
            <UFormField label="Taille du client" name="clientFinalTaille">
              <UInput v-model="form.clientFinalTaille" placeholder="Ex. PME, grand compte" class="w-full" />
            </UFormField>
          </template>

          <UFormField label="Apporteur" name="apporteurId" required>
            <USelectMenu
              v-model="form.apporteurId"
              :items="membres"
              value-key="id"
              label-key="label"
              placeholder="Choisir un apporteur"
              :loading="chargementOptions"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Moteur (facultatif)" name="moteurId">
            <USelectMenu
              v-model="form.moteurId"
              :items="membres"
              value-key="id"
              label-key="label"
              placeholder="Choisir un moteur"
              :loading="chargementOptions"
              clear
              class="w-full"
            />
          </UFormField>
        </section>
      </CarteTitree>

      <CarteTitree
        icon="i-lucide-list-checks"
        title="Conditions de la mission"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField label="Technologies" name="technologies" class="md:col-span-2">
            <UInputMenu
              v-model="form.technologies"
              :items="technologiesDisponibles"
              multiple
              create-item="always"
              placeholder="Rechercher, choisir ou ajouter des technologies"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Technologie principale" name="technologiePrincipale">
            <USelect
              v-model="form.technologiePrincipale"
              :items="form.technologies"
              placeholder="Aucune"
              :disabled="form.technologies.length === 0"
              class="w-full"
            />
          </UFormField>

          <UFormField label="Ville" name="ville">
            <UInput v-model="form.ville" placeholder="Ex. Paris" class="w-full" />
          </UFormField>

          <UFormField label="Mode de travail" name="mode">
            <USelect v-model="form.mode" :items="modes" placeholder="Sélectionner" class="w-full" />
          </UFormField>

          <UFormField label="Température" name="temperature">
            <USelect v-model="form.temperature" :items="temperatures" placeholder="Sélectionner" class="w-full" />
          </UFormField>

          <UFormField label="TJM annoncé (€)" name="tjmAnnonce">
            <UInputNumber v-model="form.tjmAnnonce" :min="0" :step="10" class="w-full" />
          </UFormField>

          <UFormField label="TJM client (€)" name="tjmClient">
            <UInputNumber v-model="form.tjmClient" :min="0" :step="10" class="w-full" />
          </UFormField>

          <UFormField label="Durée annoncée (mois)" name="dureeAnnonceeMois">
            <UInputNumber v-model="form.dureeAnnonceeMois" :min="0.5" :step="0.5" class="w-full" />
          </UFormField>

          <UFormField label="Charge" name="charge">
            <USelect v-model="form.charge" :items="charges" placeholder="Sélectionner" class="w-full" />
          </UFormField>

          <UFormField label="Timing" name="timing">
            <USelect v-model="form.timing" :items="timings" placeholder="Sélectionner" class="w-full" />
          </UFormField>

          <UFormField label="Date du signal" name="dateSignal" required>
            <UInput v-model="form.dateSignal" type="date" class="w-full" />
          </UFormField>
        </section>
      </CarteTitree>

      <CarteTitree
        icon="i-lucide-send"
        title="Candidature et diffusion"
      >
        <section class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UFormField label="Mode de candidature" name="modeCandidature">
            <USelect v-model="form.modeCandidature" :items="modesCandidature" placeholder="Sélectionner" class="w-full" />
          </UFormField>

          <UFormField label="Précision du mode de candidature" name="modeCandidaturePrecision">
            <UInput v-model="form.modeCandidaturePrecision" placeholder="Nom, mail ou canal de contact" class="w-full" />
          </UFormField>

          <UFormField label="Niveau de diffusion" name="niveauDiffusion" class="md:col-span-2">
            <URadioGroup
              v-model="form.niveauDiffusion"
              :items="niveauxDiffusion"
              orientation="vertical"
            />
          </UFormField>

          <UFormField label="Lien de l'annonce extérieure" name="lienAnnonceExterieure" class="md:col-span-2">
            <UInput
              v-model="form.lienAnnonceExterieure"
              type="url"
              placeholder="https://…"
              class="w-full"
            />
          </UFormField>
        </section>
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
interface OptionsOpportunite {
  membres: { id: string, nom: string, prenom: string, mail: string }[]
  entreprises: string[]
  technologies: string[]
}

const router = useRouter()
const toast = useToast()
const { user } = useAuth()
const { data: options, pending: chargementOptions, error: erreurOptions } = await useFetch<OptionsOpportunite>('/api/opportunites/options', {
  default: () => ({ membres: [], entreprises: [], technologies: [] })
})

const form = reactive({
  titre: '',
  source: undefined as string | undefined,
  typeMission: undefined as string | undefined,
  niveauRecherche: undefined as string | undefined,
  apporteurId: user.value?.id ?? '',
  moteurId: undefined as string | undefined,
  clientFinal: undefined as string | undefined,
  clientFinalSecteur: '',
  clientFinalTaille: '',
  tjmAnnonce: undefined as number | undefined,
  tjmClient: undefined as number | undefined,
  dureeAnnonceeMois: undefined as number | undefined,
  charge: undefined as string | undefined,
  timing: undefined as string | undefined,
  ville: '',
  mode: undefined as string | undefined,
  temperature: undefined as string | undefined,
  modeCandidature: undefined as string | undefined,
  modeCandidaturePrecision: '',
  niveauDiffusion: 'reseau_perso',
  lienAnnonceExterieure: '',
  dateSignal: new Date().toISOString().slice(0, 10),
  technologies: [] as string[],
  technologiePrincipale: undefined as string | undefined
})

const membres = computed(() => (options.value?.membres ?? []).map(m => ({
  ...m,
  label: `${m.prenom} ${m.nom} (${m.mail})`
})))
const entreprises = computed(() => options.value?.entreprises ?? [])
const technologiesDisponibles = computed(() => options.value?.technologies ?? [])

const sources = [
  { label: 'Client', value: 'client' },
  { label: 'Commercial (ESN)', value: 'commercial' },
  { label: 'Contact', value: 'contact' }
]
const typesMission = ['Run', 'Build', 'Expertise']
const niveaux = [
  { label: 'Opérationnel', value: 'operationnel' },
  { label: 'Senior', value: 'senior' },
  { label: 'Expert', value: 'expert' }
]
const modes = [
  { label: 'Télétravail', value: 'teletravail' },
  { label: 'Hybride', value: 'hybride' },
  { label: 'Présentiel', value: 'presentiel' }
]
const temperatures = [
  { label: 'Chaud', value: 'chaud' },
  { label: 'Tiède', value: 'tiede' }
]
const charges = ['Temps plein', '3-4 jours par semaine', '1-2 jours par semaine']
const timings = [
  { label: 'Urgent', value: 'urgent' },
  { label: 'Dans moins d’un mois', value: 'moins_1_mois' },
  { label: 'Dans plus d’un mois', value: 'plus_1_mois' }
]
const modesCandidature = [
  { label: 'Via l’apporteur', value: 'via_apporteur' },
  { label: 'Contact direct recruteur', value: 'contact_direct_recruteur' },
  { label: 'Via le moteur', value: 'via_moteur' }
]
const niveauxDiffusion = [
  { label: 'Libre', value: 'libre', description: 'Le relais public de l’opportunité est autorisé.' },
  { label: 'Réseau personnel', value: 'reseau_perso', description: 'Partage de personne à personne, choix recommandé.' },
  { label: 'Interne strict', value: 'interne_strict', description: 'Réservé aux membres du collectif.' }
]

const creation = ref(false)

watch(() => form.technologies, (selection) => {
  if (form.technologiePrincipale && !selection.includes(form.technologiePrincipale)) {
    form.technologiePrincipale = undefined
  }
}, { deep: true })

watch(entreprises, (liste) => {
  if (form.clientFinal && !liste.includes(form.clientFinal)) {
    form.clientFinal = undefined
  }
})

async function creer() {
  if (!form.titre.trim()) {
    toast.add({ title: 'Le titre est obligatoire.', color: 'error' })
    return
  }
  if (!form.apporteurId) {
    toast.add({ title: 'Sélectionnez un apporteur.', color: 'error' })
    return
  }

  creation.value = true
  try {
    const resultat = await $fetch<{ id: string }>('/api/opportunites', {
      method: 'POST',
      body: {
        ...form,
        clientFinal: form.clientFinal?.trim() || undefined,
        clientFinalSecteur: form.clientFinalSecteur.trim() || undefined,
        clientFinalTaille: form.clientFinalTaille.trim() || undefined,
        typeMission: form.typeMission?.trim() || undefined,
        modeCandidaturePrecision: form.modeCandidaturePrecision.trim() || undefined,
        lienAnnonceExterieure: form.lienAnnonceExterieure.trim() || undefined
      }
    })
    toast.add({ title: 'Opportunité créée avec succès', color: 'success' })
    await router.push(`/opportunites/${resultat.id}`)
  } catch (error) {
    const message = (error as { data?: { statusMessage?: string } }).data?.statusMessage
    toast.add({ title: 'Création impossible', description: message, color: 'error' })
  } finally {
    creation.value = false
  }
}
</script>
