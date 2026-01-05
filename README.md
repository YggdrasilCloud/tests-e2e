# YggdrasilCloud E2E Tests

Infrastructure de tests end-to-end pour YggdrasilCloud, utilisant Playwright et Docker Compose.

## 📋 Prerequisites

- Docker & Docker Compose
- Node.js 18+

## 🏗️ Architecture

Les tests E2E utilisent une infrastructure complètement isolée avec des ports différents du développement :

| Service | Dev | E2E Test |
|---------|-----|----------|
| Database | 5432 | **5433** |
| Backend | 8000 | **8001** |
| Frontend | 5173 | **5174** |

Cela permet de lancer les tests **en parallèle** avec l'environnement de développement sans conflit.

### Git Submodule

Les tests sont stockés dans le repository **frontend** et référencés ici via un **git submodule** :

```
tests-e2e/
└── frontend-submodule/     # Git submodule → ../frontend
    └── tests/e2e/          # Tests Playwright
        ├── folders.spec.ts
        ├── photos.spec.ts
        ├── lightbox.spec.ts
        └── folder-creation.spec.ts
```

**Avantages** :
- ✅ **Single Source of Truth** : Tests maintenus dans `frontend/`
- ✅ **Pas de duplication** : Une seule copie des tests
- ✅ **Versioning strict** : Pointeur vers un commit SHA spécifique
- ✅ **CI/CD simple** : `git clone --recurse-submodules`

## 🚀 Quick Start

```bash
# 1. Cloner avec submodules
git clone --recurse-submodules https://github.com/YggdrasilCloud/tests-e2e.git
cd tests-e2e

# 2. Installer Playwright
npm install

# 3. Démarrer tous les services (DB, Backend, Frontend)
npm run setup

# 4. Seeder les données de test
npm run seed

# 5. Lancer les tests
npm test
```

## 📦 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run setup` | Démarre tous les services Docker (DB + Backend + Frontend) |
| `npm run seed` | Seed la base de données avec des données de test |
| `npm test` | Lance tous les tests E2E (175/180 passent ✅) |
| `npm run test:chromium` | Lance les tests sur Chromium uniquement |
| `npm run test:ui` | Ouvre Playwright UI mode |
| `npm run test:debug` | Lance les tests en mode debug |
| `npm run test:headed` | Lance les tests avec interface graphique |
| `npm run test:report` | Ouvre le rapport HTML des tests |
| `docker compose logs -f` | Affiche les logs en temps réel |
| `docker compose down` | Arrête les services |
| `docker compose down -v` | Arrête et nettoie les volumes |

## 🔄 Workflow Développeur

### Workflow 1 : Développement actif (dev + tests)

Lancer dev ET tests en parallèle :

```bash
# Terminal 1: Dev environment (ports 5432, 8000, 5173)
cd ../core && docker compose up -d
cd ../frontend && npm run dev

# Terminal 2: E2E tests (ports 5433, 8001, 5174)
cd tests-e2e
npm run setup
npm run seed
npm test
```

### Workflow 2 : Tests uniquement

```bash
npm run setup    # Démarre DB + Backend + Frontend
npm run seed     # Seed les données
npm test         # Lance les tests
```

### Workflow 3 : Mettre à jour les tests depuis frontend

Après avoir modifié un test dans `frontend/tests/e2e/` :

```bash
# 1. Dans frontend : commit et push
cd frontend
git add tests/e2e/my-test.spec.ts
git commit -m "Add new E2E test"
git push

# 2. Dans tests-e2e : mettre à jour le submodule
cd tests-e2e
git submodule update --remote frontend-submodule
git add frontend-submodule
git commit -m "Update frontend tests to latest"
git push
```

## 🌱 Test Data

Le seed crée automatiquement :

**3 dossiers** :
- `Vacation Photos 2024` (5 photos)
- `Family Memories` (vide)
- `Empty Folder` (vide)

**5 photos** dans "Vacation Photos 2024" :
- blue-sample.jpg (5.9 KB)
- green-sample.jpg (9.5 KB)
- red-sample.jpg (3.9 KB)
- nasa-earth.jpg (7.2 MB)
- met-still-life.jpg (4.1 MB)

### Re-seeding

```bash
npm run seed
```

Le seed est **idempotent** : il purge et recrée les données à chaque fois.

## 🎭 Playwright Configuration

Les tests s'exécutent sur **5 navigateurs** :

1. **Chromium** (Desktop Chrome)
2. **Firefox** (Desktop Firefox)
3. **WebKit** (Desktop Safari)
4. **Mobile Chrome** (Pixel 5)
5. **Mobile Safari** (iPhone 12)

**Total** : **180 tests** (36 tests × 5 browsers)
**Résultat** : ✅ **175 passent** (97%) | ⏭️ 5 skipped (3%)

### Run specific browser

```bash
npm test -- --project=chromium
npm test -- --project=firefox
npm test -- --project=webkit
```

### Run specific test file

```bash
npm test -- folders.spec.ts
npm test -- photos.spec.ts --project=chromium
```

### Debug mode

```bash
npm run test:debug
# Ou avec Playwright Inspector :
npx playwright test --debug
```

## 📊 Test Reports

Après l'exécution des tests :

```bash
npm run test:report
```

Le rapport HTML inclut :
- ✅ Résultats des tests
- 📸 Screenshots des échecs
- 🎥 Vidéos des tests
- 🌐 Logs réseau

## 🐛 Troubleshooting

### Les services ne démarrent pas

```bash
# Vérifier les logs
docker compose logs backend
docker compose logs frontend

# Nettoyer et redémarrer
docker compose down -v
npm run setup
```

### Les tests échouent

```bash
# Vérifier que les services sont UP et healthy
docker compose ps

# Re-seeder les données
npm run seed

# Lancer un seul test pour débugger
npm test -- folders.spec.ts --project=chromium --headed
```

### Le submodule est vide

```bash
git submodule update --init --recursive
```

### Conflits de ports

Si les ports 5433, 8001 ou 5174 sont déjà utilisés :

```bash
# Trouver le processus
lsof -i :5433

# Ou modifier compose.yaml
```

### Backend ne démarre pas (permissions)

Le backend s'exécute avec `chmod -R 777 /app` pour éviter les problèmes de permissions. Si vous voyez des erreurs de permissions, vérifiez les logs :

```bash
docker compose logs backend | tail -50
```

## 🔧 CI/CD

### GitHub Actions

Pour cloner le repo avec submodules en CI :

```yaml
- uses: actions/checkout@v4
  with:
    submodules: true  # Clone automatiquement frontend-submodule

- name: Install dependencies
  run: npm ci

- name: Start services
  run: npm run setup

- name: Seed test data
  run: npm run seed

- name: Run E2E tests
  run: npm test

- name: Upload test report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: playwright-report
    path: playwright-report/
```

### Déclencher les tests E2E depuis frontend

Utilisez `repository_dispatch` pour déclencher les tests E2E quand le frontend change :

```yaml
# Dans frontend/.github/workflows/ci.yml
- name: Trigger E2E tests
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.PAT_TOKEN }}
    repository: YggdrasilCloud/tests-e2e
    event-type: run-e2e
```

## 📁 Project Structure

```
tests-e2e/
├── .github/workflows/      # GitHub Actions CI
├── frontend-submodule/     # Git submodule → ../frontend
│   └── tests/e2e/         # 36 tests Playwright (175/180 passent ✅)
├── fixtures/               # Photos de test
│   └── photos/
│       ├── blue-sample.jpg
│       ├── green-sample.jpg
│       ├── red-sample.jpg
│       ├── nasa-earth.jpg
│       └── met-still-life.jpg
├── scripts/
│   ├── setup.sh           # Démarre les services
│   ├── seed.sh            # Seed les données de test
│   └── run-tests.sh       # Lance les tests
├── compose.yaml            # DB + Backend + Frontend
├── Caddyfile              # Config FrankenPHP pour tests
├── playwright.config.ts    # Config Playwright
├── global-setup.ts         # Validation avant tests
└── package.json
```

## 🔗 Git Submodules

### Commandes utiles

```bash
# Cloner avec submodules
git clone --recurse-submodules <repo-url>

# Initialiser submodule après clone sans --recurse-submodules
git submodule update --init --recursive

# Mettre à jour vers le dernier commit de frontend
git submodule update --remote frontend-submodule

# Mettre à jour vers un commit spécifique
cd frontend-submodule
git checkout <commit-sha>
cd ..
git add frontend-submodule
git commit -m "Update to specific frontend commit"

# Pull avec mise à jour des submodules
git pull --recurse-submodules
```

### Vérifier l'état du submodule

```bash
git submodule status
# Affiche : <SHA> frontend-submodule (<branch>)
```

## 🤝 Contributing

### Ajouter un nouveau test

1. **Écrire le test dans frontend** :
   ```bash
   cd ../frontend
   vim tests/e2e/my-feature.spec.ts
   git add tests/e2e/my-feature.spec.ts
   git commit -m "Add E2E test for my feature"
   git push
   ```

2. **Mettre à jour tests-e2e** :
   ```bash
   cd ../tests-e2e
   git submodule update --remote frontend-submodule
   git add frontend-submodule
   git commit -m "Update frontend tests"
   git push
   ```

3. **Lancer le test** :
   ```bash
   npm test -- my-feature.spec.ts
   ```

### Conventions

- Nommer les tests : `*.spec.ts`
- Descriptions : `test('should ...')`
- Toujours tester sur tous les navigateurs
- Ajouter des fixtures dans `fixtures/` si nécessaire

## 📚 Resources

- [Playwright Documentation](https://playwright.dev/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Git Submodules Guide](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Frontend Repository](https://github.com/YggdrasilCloud/frontend)
- [Backend Repository](https://github.com/YggdrasilCloud/core)
