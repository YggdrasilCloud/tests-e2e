# Workflow automatisé E2E

## 🔄 Comment ça fonctionne

Ce repository utilise un système **100% automatisé** pour maintenir les tests E2E à jour.

### Architecture

```
core (backend)           frontend (UI)           docker (images)
     ↓                        ↓                        ↓
  push main                push main               push main
     ↓                        ↓                        ↓
workflow:                workflow:               workflow:
update-e2e.yml          update-e2e.yml          update-e2e.yml
     ↓                        ↓                        ↓
     └────────────────────────┴────────────────────────┘
                              ↓
                    tests-e2e (ce repo)
                    Submodule mis à jour
                              ↓
                        workflow: e2e.yml
                    185 tests E2E exécutés
                              ↓
                    ✅ ou ❌ (notification)
```

---

## 🚀 Workflow développeur

### Option 1 : Développement normal (automatique)

```bash
# 1. Travaillez dans core, frontend ou docker
cd ~/workspace/github/YggdrasilCloud/core
# ... faites vos modifications ...
git add .
git commit -m "Add new feature"
git push origin main

# 2. ✨ MAGIE : Rien à faire !
# - Le workflow update-e2e.yml se déclenche automatiquement
# - tests-e2e/core-submodule est mis à jour
# - Les 185 tests E2E se lancent
# - Vous recevez une notification si ça échoue
```

### Option 2 : Tester localement avant de push

```bash
# Dans tests-e2e
cd ~/workspace/github/YggdrasilCloud/tests-e2e

# Démarrer les services
npm run setup

# Seeder les données de test
npm run seed

# Lancer les tests
npm test

# Nettoyer
npm run cleanup
```

---

## 📊 Vérifier les résultats

### Dans GitHub Actions

1. **Après un push vers core/frontend/docker** :
   - Aller sur https://github.com/YggdrasilCloud/core/actions (ou frontend/docker)
   - Voir le workflow "Update E2E Tests" s'exécuter (~30 secondes)

2. **Ensuite automatiquement** :
   - Aller sur https://github.com/YggdrasilCloud/tests-e2e/actions
   - Voir le workflow "E2E Tests" s'exécuter (~6-7 minutes)
   - Résultat : ✅ 185 passed ou ❌ X failed

### Notifications

Vous recevez une notification GitHub (email/web) si :
- ❌ Les tests E2E échouent
- ❌ Le workflow de mise à jour échoue

Pas de notification si tout passe ✅ (moins de spam).

---

## 🔧 Configuration requise

### Secrets GitHub requis

Chaque repository doit avoir le secret **`PAT_TOKEN`** configuré :

- ✅ **core** → Settings → Secrets → Actions → `PAT_TOKEN`
- ✅ **frontend** → Settings → Secrets → Actions → `PAT_TOKEN`
- ✅ **docker** → Settings → Secrets → Actions → `PAT_TOKEN`
- ✅ **tests-e2e** → Settings → Secrets → Actions → `PAT_TOKEN`

**Scope requis** : `repo` (Full control of private repositories)

### Créer/Renouveler le PAT

1. Aller sur https://github.com/settings/tokens
2. Generate new token (classic)
3. Scopes : ✅ `repo`
4. Copier le token
5. L'ajouter dans chaque repository

---

## 🐛 Dépannage

### Le submodule n'est pas mis à jour automatiquement

**Vérifier** :
1. Le workflow existe : `.github/workflows/update-e2e.yml` dans core/frontend/docker
2. Le secret `PAT_TOKEN` est configuré
3. Le workflow n'a pas échoué : https://github.com/YggdrasilCloud/core/actions

**Solution** : Relancer le workflow manuellement ou vérifier les logs.

### Les tests E2E échouent après une mise à jour

**Scénario normal** : Votre changement a cassé quelque chose !

**Actions** :
1. Voir les logs détaillés : https://github.com/YggdrasilCloud/tests-e2e/actions
2. Télécharger les screenshots/vidéos d'échec
3. Corriger le bug
4. Pusher le fix → les tests se relancent automatiquement

### Mise à jour manuelle du submodule (si besoin)

```bash
cd ~/workspace/github/YggdrasilCloud/tests-e2e
git submodule update --remote core-submodule      # ou frontend-submodule, docker-submodule
git add core-submodule
git commit -m "Manual update of core-submodule"
git push origin main
```

---

## 📈 Statistiques

- **Temps de mise à jour automatique** : ~30 secondes
- **Temps d'exécution E2E** : ~6-7 minutes
- **Total** : ~7-8 minutes du push au résultat
- **Tests exécutés** : 185 (37 scénarios × 5 navigateurs)
- **Taux de réussite attendu** : 100% ✅

---

## 🎯 Bonnes pratiques

1. **Toujours pusher vers main après avoir testé localement**
2. **Vérifier les résultats E2E avant de merger une PR**
3. **Ne pas ignorer les échecs E2E** (ils détectent les régressions)
4. **Ajouter des tests E2E pour chaque nouvelle feature**

---

## 📚 Ressources

- [Guide Playwright](https://playwright.dev/docs/intro)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
