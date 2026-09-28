<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'
import { Role } from '#shared/types/utilisateur'

const { isAuthenticated, role } = useAuth()

const items = computed<NavigationMenuItem[]>(() => [
  { label: 'Opportunités', icon: 'i-lucide-briefcase', to: '/' },
  { label: 'Contacts', icon: 'i-lucide-users', to: '/contacts' },
  { label: 'Profils extérieurs', icon: 'i-lucide-user-search', to: '/profils-exterieurs' },
  ...(role.value === Role.admin
    ? [
        { label: 'Comptes', icon: 'i-lucide-shield', to: '/comptes' }
      ]
    : [])
])
</script>

<template>
  <UHeader
    title="CRM Koloni"
    mode="slideover"
    toggle-side="left"
    :menu="{ side: 'left' }"
    :toggle="{
      color: 'success',
      variant: 'subtle',
      class: 'full'
    }"
  >
    <UNavigationMenu
      :items="items"
      aria-label="Navigation principale"
    />
    <template #right>
      <InfoUtilisateur v-if="isAuthenticated" />
      <UColorModeButton />
    </template>
    <template #body>
      <UNavigationMenu
        :items="items"
        orientation="vertical"
        class="-mx-2.5"
        aria-label="Navigation mobile"
      />
    </template>
  </UHeader>
</template>
