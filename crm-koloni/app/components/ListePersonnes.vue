<!--
  ListePersonnes — groupe de personnes affichées en puces, chacune supprimable
  Ne s'affiche pas si la liste est vide.
  Props :
    personnes — personnes à afficher
    label     — titre du groupe (suivi du nombre de personnes)
    color     — couleur des puces et du compteur : 'primary' (défaut) ou 'secondary'
    display   — texte de chaque puce : 'nomComplet' (défaut) ou 'mail'
  Émet : remove(personne) au clic sur la croix d'une puce
-->
<template>
  <section
    v-if="personnes.length > 0"
    class="space-y-2"
  >
    <header class="flex items-center gap-2">
      <p class="text-sm font-medium text-gray-700 dark:text-gray-300">
        {{ label }}
      </p>
      <UBadge
        :label="String(personnes.length)"
        :color="color"
        size="sm"
        variant="soft"
      />
    </header>
    <ul class="flex flex-wrap gap-2">
      <li
        v-for="personne in personnes"
        :key="personne.id"
        :class="['inline-flex max-w-xs items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium ring-1', COULEURS[color].puce]"
      >
        <span class="truncate">{{ libellePuce(personne) }}</span>
        <button
          type="button"
          :class="['shrink-0 rounded-full p-0.5 transition-colors', COULEURS[color].croix]"
          :aria-label="`Retirer ${libellePuce(personne)}`"
          @click="emit('remove', personne)"
        >
          <UIcon
            name="i-lucide-x"
            class="size-3"
          />
        </button>
      </li>
    </ul>
  </section>
</template>

<script lang="ts" setup>
const props = withDefaults(defineProps<{
  personnes: PersonneListee[]
  label: string
  color?: 'primary' | 'secondary'
  display?: 'nomComplet' | 'mail'
}>(), {
  color: 'primary',
  display: 'nomComplet'
})

const emit = defineEmits<{ remove: [personne: PersonneListee] }>()

// Classes propres à chaque couleur, écrites en entier pour que Tailwind les détecte
const COULEURS = {
  primary: {
    puce: 'bg-primary-50 dark:bg-primary-950 text-primary-700 dark:text-primary-300 ring-primary-200 dark:ring-primary-800',
    croix: 'hover:bg-primary-200 dark:hover:bg-primary-800'
  },
  secondary: {
    puce: 'bg-secondary-50 dark:bg-secondary-950 text-secondary-700 dark:text-secondary-300 ring-secondary-200 dark:ring-secondary-800',
    croix: 'hover:bg-secondary-200 dark:hover:bg-secondary-800'
  }
}

function libellePuce(personne: PersonneListee): string {
  return props.display === 'mail' ? personne.mail : `${personne.prenom} ${personne.nom}`
}
</script>
