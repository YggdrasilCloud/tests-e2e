# Quick Start Guide

## 🚀 For Developers (Local Development)

### First Time Setup

```bash
# 1. Clone the repo
git clone git@github.com:YggdrasilCloud/tests-e2e.git
cd tests-e2e

# 2. Install dependencies
npm install

# 3. Start database
npm run setup
```

### Daily Workflow

You're actively coding on backend/frontend and want to test:

```bash
# Terminal 1: Database (keep running)
docker compose up -d db

# Terminal 2: Backend
cd ../backend
npm run dev

# Terminal 3: Frontend
cd ../frontend
npm run dev

# Terminal 4: Tests (run when needed)
cd ../tests-e2e
npm run seed  # Only once, or after schema changes
npm test      # Run tests anytime
```

### Quick Commands

```bash
# Run all tests
npm test

# Run with UI (great for debugging)
npm run test:ui

# Run specific test file
npx playwright test tests/folders.spec.ts

# Run specific browser
npx playwright test --project=chromium

# See test report
npm run test:report
```

## 🐳 For CI/CD (Full Docker)

### One-Time Setup

```bash
git clone git@github.com:YggdrasilCloud/tests-e2e.git
cd tests-e2e
npm install
```

### Run Tests Against Docker Images

```bash
# Pull latest images and run tests
docker compose --profile compose up -d
npm run seed
npm test

# Cleanup
npm run cleanup
```

### Test Specific Versions

```bash
# Set versions
export BACKEND_VERSION=abc123
export FRONTEND_VERSION=def456

# Run tests
docker compose --profile compose up -d
npm run seed
npm test
```

## 🔧 Common Tasks

### Reseed Data

After changing database schema or needing fresh data:

```bash
npm run seed
```

### Cleanup Everything

Remove all containers and volumes:

```bash
npm run cleanup
```

### Debug Failing Test

```bash
# Run in headed mode (see browser)
npm run test:headed

# Or use debug mode (step through)
npm run test:debug

# Or use UI mode (best for debugging)
npm run test:ui
```

### Check Service Status

```bash
# See what's running
docker compose ps

# View logs
docker compose logs backend
docker compose logs frontend
docker compose logs db
```

## 🎯 Cheat Sheet

| Scenario | Command |
|----------|---------|
| First time setup | `npm install && npm run setup` |
| Daily dev workflow | `docker compose up -d db` then run backend/frontend locally |
| Quick test run | `npm run e2e` (auto-detects services) |
| Debug test | `npm run test:ui` |
| Reseed data | `npm run seed` |
| Full cleanup | `npm run cleanup` |
| CI-like test | `docker compose --profile compose up -d && npm run seed && npm test` |

## 🆘 Troubleshooting

### "Application not ready after 60 seconds"

**Fix**:
```bash
# Check services
docker compose ps

# Restart everything
npm run cleanup
npm run setup
```

### "No folders available for testing"

**Fix**:
```bash
npm run seed
```

### "Port already in use"

**Fix**:
```bash
# Stop conflicting service
docker ps
docker stop <container-id>

# Or kill the process
lsof -ti:5432 | xargs kill
lsof -ti:8000 | xargs kill
lsof -ti:5173 | xargs kill
```

### Tests are slow

**Fix**:
```bash
# Run fewer browsers
npx playwright test --project=chromium

# Or increase workers
npx playwright test --workers=8
```

## 📚 Next Steps

- Read [README.md](README.md) for detailed documentation
- Check [MIGRATION.md](MIGRATION.md) to migrate existing tests
- See [TODO.md](TODO.md) for implementation tasks
- View [Playwright docs](https://playwright.dev) for test writing

## 💡 Pro Tips

1. **Keep database running**: `docker compose up -d db` and leave it
2. **Use test:ui**: Best way to develop and debug tests
3. **Seed once**: Only reseed when schema changes, not before every test run
4. **Watch mode**: In test:ui, tests auto-rerun on file changes
5. **Screenshots**: Failed tests automatically save screenshots in `test-results/`
6. **Parallel tests**: Tests run in parallel by default (faster)
7. **Trace viewer**: `npx playwright show-trace test-results/.../trace.zip`

## 🎓 Learning Resources

- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Selectors Guide](https://playwright.dev/docs/selectors)
- [Test Fixtures](https://playwright.dev/docs/test-fixtures)
- [CI Configuration](https://playwright.dev/docs/ci)
