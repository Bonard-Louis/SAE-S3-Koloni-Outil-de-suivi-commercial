<template>
  <div class="flex min-h-screen items-center justify-center bg-elevated/30 p-4">
    <UAuthForm
      :schema="schema"
      :fields="fields"
      :loading="loading"
      title="Créer un compte"
      description="Rejoignez Koloni CRM"
      icon="i-lucide-user-plus"
      :submit="{ label: 'Créer le compte' }"
      class="w-full max-w-sm"
      @submit="onSubmit"
    >
      <template #footer>
        <p class="text-center text-sm text-muted">
          Déjà un compte ?
          <ULink
            to="/connexion/login"
            class="font-medium text-primary"
          >
            Se connecter
          </ULink>
        </p>
      </template>
    </UAuthForm>
  </div>
</template>

<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

// Page réservée aux administrateurs (EF-02) : l'accès est contrôlé par le middleware d'authentification.
definePageMeta({ layout: false })

const schema = z.object({
  prenom: z.string().min(1, 'Le prénom est requis'),
  nom: z.string().min(1, 'Le nom est requis'),
  mail: z.email('Adresse mail invalide'),
  password: z.string().min(8, 'Le mot de passe doit contenir au moins 8 caractères'),
  confirmation: z.string().min(1, 'La confirmation est requise')
}).refine(data => data.password === data.confirmation, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['confirmation']
})

const fields = [
  {
    name: 'prenom',
    type: 'text' as const,
    label: 'Prénom',
    placeholder: 'Jean',
    required: true
  },
  {
    name: 'nom',
    type: 'text' as const,
    label: 'Nom',
    placeholder: 'Dupont',
    required: true
  },
  {
    name: 'mail',
    type: 'text' as const,
    label: 'Adresse mail',
    placeholder: 'vous@exemple.fr',
    required: true
  },
  {
    name: 'password',
    type: 'password' as const,
    label: 'Mot de passe',
    placeholder: 'Votre mot de passe',
    required: true
  },
  {
    name: 'confirmation',
    type: 'password' as const,
    label: 'Confirmation du mot de passe',
    placeholder: 'Confirmez votre mot de passe',
    required: true
  }
]

type Schema = z.output<typeof schema>

const loading = ref(false)
const toast = useToast()

async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true
  try {
    const { prenom, nom, mail, password } = event.data
    await $fetch('/api/comptes', { method: 'POST', body: { prenom, nom, mail, password } })
    toast.add({ title: 'Compte créé', color: 'success' })
  } catch (error) {
    const message = (error as { data?: { statusMessage?: string } }).data?.statusMessage
    toast.add({ title: 'Création impossible', description: message, color: 'error' })
  } finally {
    loading.value = false
  }
}
</script>
