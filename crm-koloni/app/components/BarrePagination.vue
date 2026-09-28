<!--
  PaginationBar — barre de pagination centrée réutilisable
  Props : page (courante), total (nombre d'éléments), itemsPerPage (éléments par page)
  v-model:page : page courante (emit update:page)
-->
<template>
  <section class="flex justify-center">
    <UPagination
      :page="page"
      :total="total"
      :items-per-page="itemsPerPage"
      @update:page="$emit('update:page', $event)"
    />
  </section>
</template>

<script lang="ts" setup>
defineProps<{
  page: number
  total: number
  itemsPerPage: number
}>()

defineEmits<{
  'update:page': [value: number]
}>()
</script>
