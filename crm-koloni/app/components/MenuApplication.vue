<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'
import { Role } from '#shared/types/utilisateur'

const { isAuthenticated, role, logout } = useAuth()
const enDeconnexion = ref(false)
const router = useRouter()

const items = computed<NavigationMenuItem[]>(() => [
  { label: 'Dashboard', icon: 'i-lucide-layout-dashboard', to: '/' },
  { label: 'Opportunités', icon: 'i-lucide-briefcase', to: '/opportunites' },
  { label: 'Contacts', icon: 'i-lucide-users', to: '/contacts' },
  { label: 'Profils extérieurs', icon: 'i-lucide-user-search', to: '/profils-exterieurs' },
  ...(role.value === Role.admin
    ? [
        { label: 'Comptes', icon: 'i-lucide-shield', to: '/comptes' }
      ]
    : [])
])

async function deconnecter() {
  if (enDeconnexion.value) return
  enDeconnexion.value = true
  try {
    await logout()
    await router.push('/connexion/login')
  } finally {
    enDeconnexion.value = false
  }
}
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
      <UButton
        v-if="isAuthenticated"
        icon="i-lucide-log-out"
        color="neutral"
        variant="ghost"
        :loading="enDeconnexion"
        @click="deconnecter"
      />
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
      <UButton
        v-if="isAuthenticated"
        label="Déconnexion"
        icon="i-lucide-log-out"
        color="neutral"
        variant="ghost"
        class="mt-4 w-full"
        :loading="enDeconnexion"
        @click="deconnecter"
      />
    </template>
  </UHeader>
</template>
