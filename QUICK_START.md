# Quick Start Guide

## 🚀 Simple Workflow (Everything in Docker)

### First Time Setup

```bash
# 1. Clone and install
git clone git@github.com:YggdrasilCloud/tests-e2e.git
cd tests-e2e
npm install

# 2. Start all services (DB + Backend + Frontend)
npm run setup

# 3. Seed test data
npm run seed

# 4. Run tests
npm test
```

That's it! 🎉

### Daily Workflow

```bash
# Start services (if not already running)
docker compose up -d

# Run tests anytime
npm test

# Stop services when done
docker compose down
```

## 📦 What's Running

After `npm run setup` or `docker compose up -d`:

| Service | URL | Container |
|---------|-----|-----------|
| Database | `postgresql://test:test@localhost:5432/yggdrasil_test` | `tests-e2e-db-1` |
| Backend (Symfony) | http://localhost:8000 | `tests-e2e-backend-1` |
| Frontend (SvelteKit) | http://localhost:5173 | `tests-e2e-frontend-1` |

Playwright runs **on your machine** (not in Docker) so you can use UI mode.

## 🎯 Common Commands

```bash
# Setup: Start all services
npm run setup

# Seed: Load test data
npm run seed

# Test: Run all tests
npm test

# Test UI: Interactive mode (best for development)
npm run test:ui

# Test headed: See the browser
npm run test:headed

# Test debug: Step through tests
npm run test:debug

# Report: View test results
npm run test:report

# Cleanup: Stop and remove everything
npm run cleanup
```

## 🎭 Playwright Modes

### Regular Mode (Headless)
```bash
npm test
```
Fast, runs in background. Good for CI or quick checks.

### UI Mode (Recommended for Development)
```bash
npm run test:ui
```
- 👁️ See tests run in browser
- ⏸️ Pause and step through
- 🔍 Inspect elements
- 📝 Watch mode (auto-rerun on file changes)

### Headed Mode
```bash
npm run test:headed
```
See actual browser windows open. Good for debugging visual issues.

### Debug Mode
```bash
npm run test:debug
```
Step through tests line by line with Playwright Inspector.

## 🔧 Working with Services

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f db
```

### Restart a Service
```bash
# Restart backend
docker compose restart backend

# Restart frontend
docker compose restart frontend
```

### Check Service Status
```bash
docker compose ps
```

### Execute Commands in Backend
```bash
# Run Symfony console command
docker compose exec backend php bin/console list

# Check backend health
curl http://localhost:8000/health
```

## 🌱 Working with Test Data

### Reseed Data
After changing database schema or when you need fresh data:

```bash
npm run seed
```

The seed command:
1. Purges the test database
2. Creates test folders
3. Uploads test photos from `fixtures/photos/`
4. Generates thumbnails and metadata

### Add Your Own Test Photos

```bash
# Add photos to fixtures directory
cp ~/Pictures/*.jpg fixtures/photos/

# Reseed to use new photos
npm run seed
```

## 🐛 Troubleshooting

### Services won't start

```bash
# Check what's using the ports
lsof -i :5432  # Database
lsof -i :8000  # Backend
lsof -i :5173  # Frontend

# Clean everything and start fresh
npm run cleanup
npm run setup
```

### Tests timeout

```bash
# Check all services are healthy
docker compose ps

# View backend health
curl http://localhost:8000/health

# View frontend
curl http://localhost:5173
```

### "No folders available for testing"

```bash
# Seed data is missing
npm run seed
```

### Backend container fails

```bash
# View backend logs
docker compose logs backend

# Common issues:
# - Database not ready → wait a bit longer
# - Image not pulled → docker compose pull backend
# - Port conflict → check port 8000
```

## 📊 Test Results

### View HTML Report
```bash
npm run test:report
```

Opens a nice HTML report with:
- ✅ Passed tests
- ❌ Failed tests
- 📸 Screenshots of failures
- 🎥 Videos of failures
- 📝 Detailed traces

### Failed Test Artifacts

When tests fail, check:
- `test-results/` - Screenshots, videos, traces
- `playwright-report/` - HTML report

### Example: Debug a Failed Test

```bash
# 1. See which tests failed
npm test

# 2. Open the report
npm run test:report

# 3. Click on failed test to see:
#    - Screenshot of failure
#    - Video of test run
#    - Network requests
#    - Console logs

# 4. Or run in UI mode to debug
npm run test:ui
```

## ⚡ Performance Tips

### Run Specific Tests
```bash
# Single file
npx playwright test tests/folders.spec.ts

# Single test
npx playwright test -g "should create folder"

# Single browser
npx playwright test --project=chromium
```

### Parallel Execution
```bash
# More workers = faster (default: CPU cores)
npx playwright test --workers=8

# One worker (for debugging)
npx playwright test --workers=1
```

## 🔄 Typical Development Loop

```bash
# 1. Start services (once)
npm run setup

# 2. Open test UI
npm run test:ui

# 3. Edit tests in your IDE
# 4. Tests auto-rerun in UI
# 5. Click through UI to debug failures

# 6. When done
docker compose down
```

## 📚 Next Steps

- Read [README.md](README.md) for detailed documentation
- Check [MIGRATION.md](MIGRATION.md) if migrating from frontend
- See [TODO.md](TODO.md) for remaining tasks
- Learn [Playwright](https://playwright.dev/docs/intro)

## 💡 Pro Tips

1. **Keep services running**: `docker compose up -d` and leave them running all day
2. **Use test:ui**: Best development experience, auto-rerun on changes
3. **Seed once**: Only reseed when schema changes, not before every test run
4. **Check logs**: `docker compose logs -f` to see what's happening
5. **Clean slate**: `npm run cleanup && npm run setup` for fresh start
6. **Trace viewer**: For deep debugging, view trace files from failed tests

## ❓ FAQ

**Q: Do I need to rebuild images when backend/frontend code changes?**
A: Yes. Pull new images: `docker compose pull` then restart: `docker compose up -d`

**Q: Can I use my local backend/frontend instead of Docker?**
A: No, this setup is Docker-only for consistency. Backend is Symfony (PHP), not Node.js.

**Q: Why is Playwright not in Docker?**
A: Running on host allows UI mode (`npm run test:ui`) which is essential for development.

**Q: How do I test against specific versions?**
A: Set env vars:
```bash
BACKEND_VERSION=abc123 FRONTEND_VERSION=def456 docker compose up -d
```

**Q: Tests are slow, how to speed up?**
A: Run fewer browsers:
```bash
npx playwright test --project=chromium
```
