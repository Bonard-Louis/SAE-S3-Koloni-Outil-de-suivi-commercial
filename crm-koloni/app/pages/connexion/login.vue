<template>
  <div class="flex min-h-screen items-center justify-center bg-elevated/30 p-4">
    <UAuthForm
      :schema="schema"
      :fields="fields"
      :loading="loading"
      title="Connexion"
      description="Accédez à votre espace Koloni CRM"
      icon="i-lucide-log-in"
      :submit="{ label: 'Se connecter' }"
      class="w-full max-w-sm"
      @submit="onSubmit"
    >
      <template #footer>
        <p class="text-center text-sm text-muted">
          Pas encore de compte ?
          <ULink
            to="/connexion/register"
            class="font-medium text-primary"
          >
            Créer un compte
          </ULink>
        </p>
      </template>
    </UAuthForm>
  </div>
</template>

<script setup lang="ts">
import * as z from 'zod'

definePageMeta({ layout: false })

const schema = z.object({
  mail: z.email('Adresse mail invalide'),
  password: z.string().min(1, 'Le mot de passe est requis')
})

const fields = [
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
  }
]

const loading = ref(false)
const toast = useToast()

async function onSubmit() {
  loading.value = true
  await new Promise(resolve => setTimeout(resolve, 600))
  loading.value = false
  toast.add({ title: 'Connexion réussie', color: 'success' })
}
</script>
