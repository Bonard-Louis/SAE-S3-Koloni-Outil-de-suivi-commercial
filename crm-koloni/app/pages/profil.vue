<template>
  <UContainer class="py-6">
    <CarteTitree
      icon="i-lucide-user"
      title="Paramètres du compte"
    >
      <div class="flex max-w-2xl flex-col gap-4">
        <dl class="grid grid-cols-[10rem_1fr] gap-y-2 text-sm">
          <dt class="font-medium">
            Nom
          </dt>
          <dd>{{ profil.nom }}</dd>
          <dt class="font-medium">
            Prénom
          </dt>
          <dd>{{ profil.prenom }}</dd>
          <dt class="font-medium">
            Mail
          </dt>
          <dd>{{ profil.mail }}</dd>
          <dt class="font-medium">
            Téléphone
          </dt>
          <dd>{{ profil.telephone }}</dd>
          <dt class="font-medium">
            Ville
          </dt>
          <dd>{{ profil.ville }}</dd>
        </dl>

        <div class="flex flex-wrap items-end gap-4">
          <ListeDeroulanteLibellee
            v-model="disponibilite"
            label="Disponibilité"
            :items="DISPONIBILITES"
          />
          <UFormField
            v-if="disponibilite === 'en_mission'"
            label="Date de fin de mission"
          >
            <UInput
              v-model="dateFinMission"
              type="date"
            />
          </UFormField>
        </div>

        <UFormField label="Note">
          <UTextarea
            v-model="note"
            placeholder="..."
            :rows="5"
            class="w-full"
          />
        </UFormField>
      </div>
    </CarteTitree>
  </UContainer>
</template>

<script setup lang="ts">
// Données de démonstration en attendant la connexion à la base de donnée
const profil = {
  nom: 'Nicolas',
  prenom: 'D.',
  mail: 'nicolas.d@koloni.fr',
  telephone: '06 00 00 00 00',
  ville: 'Toulouse'
}

const DISPONIBILITES = [
  { label: 'En recherche', value: 'en_recherche' },
  { label: 'En mission', value: 'en_mission' }
]

const disponibilite = ref('en_mission')
// Obligatoire uniquement si la disponibilité est « En mission »
const dateFinMission = ref('2026-10-10')
const note = ref('')
</script>
