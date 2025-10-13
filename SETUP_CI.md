# Configuration CI/CD pour GitHub Actions

## Problème : Submodule privé

Le workflow E2E utilise un **git submodule** (`frontend-submodule`) qui pointe vers un repository privé. Le `GITHUB_TOKEN` par défaut ne peut pas cloner les submodules privés.

## Solution : Personal Access Token (PAT)

### 1. Créer un PAT

1. Aller sur **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**

   🔗 https://github.com/settings/tokens

2. Cliquer **"Generate new token (classic)"**

3. Configurer le token :
   - **Note** : `E2E Tests Submodule Access`
   - **Expiration** : 90 days (ou No expiration)
   - **Scopes** :
     - ✅ **`repo`** (Full control of private repositories)

4. **Générer et copier le token** (il ne sera plus visible après)

### 2. Ajouter le PAT aux secrets du repo

1. Aller sur **tests-e2e → Settings → Secrets and variables → Actions**

   🔗 https://github.com/YggdrasilCloud/tests-e2e/settings/secrets/actions

2. Cliquer **"New repository secret"**

3. Configurer :
   - **Name** : `PAT_TOKEN`
   - **Secret** : Coller le token créé à l'étape 1

4. **Sauvegarder**

### 3. Vérifier que le workflow utilise le token

Le workflow `.github/workflows/e2e.yml` est déjà configuré :

```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive
    token: ${{ secrets.PAT_TOKEN || secrets.GITHUB_TOKEN }}
```

Le `|| secrets.GITHUB_TOKEN` est un fallback, mais ne fonctionnera pas pour les submodules privés.

## Alternative : Repository public

Si tu préfères rendre le repository `frontend` **public**, alors aucun PAT n'est nécessaire.

Pour rendre le repo public :
1. Aller sur https://github.com/YggdrasilCloud/frontend/settings
2. Scroll vers le bas → **Danger Zone**
3. **Change repository visibility** → Public

⚠️ **Attention** : Tous les fichiers seront visibles publiquement !

## Vérification

Une fois le PAT configuré, le workflow devrait réussir :

1. Aller sur https://github.com/YggdrasilCloud/tests-e2e/actions
2. Déclencher manuellement : **Actions → E2E Tests → Run workflow**
3. Vérifier que l'étape "Checkout repository with submodules" réussit

## Sécurité

- ✅ Le PAT est stocké de manière sécurisée dans GitHub Secrets (chiffré)
- ✅ Il n'est jamais visible dans les logs
- ✅ Il peut être révoqué à tout moment sur https://github.com/settings/tokens
- ⚠️ Pensez à le renouveler avant expiration

## Ressources

- [GitHub Actions: Checkout with submodules](https://github.com/actions/checkout#usage)
- [Creating a PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Using secrets in GitHub Actions](https://docs.github.com/en/actions/security-guides/encrypted-secrets)