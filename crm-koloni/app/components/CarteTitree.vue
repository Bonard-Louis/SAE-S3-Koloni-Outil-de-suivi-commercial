<!--
  CarteTitree — carte UCard avec un en-tête standard (icône + titre)
  Props :
    icon  — nom de l'icône Iconify (ex. 'i-lucide-users')
    title — titre affiché dans l'en-tête
  Slot par défaut : contenu de la carte
-->
<template>
  <UCard>
    <template #header>
      <header class="flex items-center gap-2">
        <UIcon
          :name="icon"
          class="size-4 text-primary-500"
        />
        <h2 class="font-semibold text-gray-900 dark:text-white">
          {{ title }}
        </h2>
      </header>
    </template>
    <slot />
  </UCard>
</template>

<script lang="ts" setup>
defineProps<{
  icon: string
  title: string
}>()
</script>
