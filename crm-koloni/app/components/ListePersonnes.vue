<!--
  ListePersonnes — liste de personnes affichées en puces avec suppression individuelle
  Props : personnes (liste), label (titre du groupe), color ('primary' | 'secondary'), display ('nomComplet' | 'mail')
  Émets : remove(personne) au clic sur la croix
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
        size="sm"
        variant="soft"
      />
    </header>
    <ul class="flex flex-wrap gap-2">
      <li
        v-for="personne in personnes"
        :key="personne.id"
        :class="chipClass"
      >
        <span class="truncate">{{ chipLabel(personne) }}</span>
        <button
          type="button"
          :class="removeClass"
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

const chipClass = computed(() =>
  props.color === 'secondary'
    ? 'inline-flex max-w-xs items-center gap-1.5 rounded-full bg-secondary-50 dark:bg-secondary-950 px-3 py-1 text-xs font-medium text-secondary-700 dark:text-secondary-300 ring-1 ring-secondary-200 dark:ring-secondary-800'
    : 'inline-flex max-w-xs items-center gap-1.5 rounded-full bg-primary-50 dark:bg-primary-950 px-3 py-1 text-xs font-medium text-primary-700 dark:text-primary-300 ring-1 ring-primary-200 dark:ring-primary-800'
)

const removeClass = computed(() =>
  props.color === 'secondary'
    ? 'shrink-0 rounded-full p-0.5 hover:bg-secondary-200 dark:hover:bg-secondary-800 transition-colors'
    : 'shrink-0 rounded-full p-0.5 hover:bg-primary-200 dark:hover:bg-primary-800 transition-colors'
)

function chipLabel(personne: PersonneListee): string {
  return props.display === 'mail' ? personne.mail : `${personne.prenom} ${personne.nom}`
}
</script>
