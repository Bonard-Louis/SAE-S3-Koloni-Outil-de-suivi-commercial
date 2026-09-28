<!--
  LabeledSelect — libellé + USelect avec style standardisé
  La largeur est automatique : un span invisible contenant l'option la plus longue
  est superposé au USelect dans la même cellule de grille CSS, ce qui force
  la cellule à prendre exactement la largeur nécessaire.
  Props : label (texte), items (options), placeholder (optionnel),
          description (optionnel — texte explicatif sous le sélecteur)
  v-model : valeur sélectionnée (string)
-->
<template>
  <div class="min-w-0 max-w-full">
    <label class="text-sm font-medium mb-1 whitespace-nowrap block">
      {{ label }}
    </label>
    <!-- Grille 1×1 : le span sizer et le USelect occupent la même cellule -->
    <div class="grid">
      <!-- Sizer invisible : fixe la largeur de la cellule sur l'option la plus longue (placeholder inclus) -->
      <span
        aria-hidden="true"
        class="invisible col-start-1 row-start-1 sm:whitespace-nowrap text-sm pl-3 pr-10"
      >{{ longestLabel }}</span>
      <USelect
        v-model="modelValue"
        :items="items"
        :placeholder="placeholder"
        class="col-start-1 row-start-1 w-full"
        :aria-label="label"
      />
    </div>
    <p
      v-if="description"
      class="text-xs text-muted mt-1"
    >
      {{ description }}
    </p>
  </div>
</template>

<script lang="ts" setup>
const props = defineProps<{
  label: string
  items: (string | { label: string, value: string | number | boolean })[]
  placeholder?: string
  description?: string
}>()

const modelValue = defineModel<string>()

// longestLabel : libellé le plus long parmi les options et le placeholder
// — sert de gabarit invisible pour dimensionner automatiquement le USelect
const longestLabel = computed(() => {
  const labels = props.items.map(item => typeof item === 'string' ? item : item.label)
  if (props.placeholder) labels.push(props.placeholder)
  return labels.reduce((max, l) => l.length > max.length ? l : max, '')
})
</script>
