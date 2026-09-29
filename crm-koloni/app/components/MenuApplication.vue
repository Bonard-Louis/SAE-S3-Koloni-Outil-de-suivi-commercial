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
      color: 'primary',
      variant: 'subtle',
      class: 'full'
    }"
  >
    <UNavigationMenu
      :items="items"
      :ui="{ link: 'hover:text-primary', linkLeadingIcon: 'group-hover:text-primary' }"
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
        :ui="{ link: 'hover:text-primary', linkLeadingIcon: 'group-hover:text-primary' }"
        aria-label="Navigation mobile"
      />
    </template>
  </UHeader>
</template>
