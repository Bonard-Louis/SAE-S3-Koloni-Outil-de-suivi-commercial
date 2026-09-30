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

// TODO : page réservée aux administrateurs (EF-02) ; accessible à tous uniquement pour les tests pour le moment.
// Restreindre l'accès au rôle administrateur une fois l'authentification branchée.
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

const loading = ref(false)
const toast = useToast()

async function onSubmit() {
  loading.value = true
  await new Promise(resolve => setTimeout(resolve, 600))
  loading.value = false
  toast.add({ title: 'Compte créé', color: 'success' })
}
</script>
