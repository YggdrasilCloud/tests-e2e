# YggdrasilCloud E2E Tests

End-to-end tests for YggdrasilCloud using Playwright.

## 📋 Prerequisites

- Docker & Docker Compose
- Node.js 18+ (for running Playwright locally)

## 🚀 Quick Start

### Option 1: Local Development (Recommended)

Use this when actively developing backend/frontend:

```bash
# 1. Start database
npm run setup

# 2. In separate terminals, start backend and frontend:
cd ../backend && npm run dev
cd ../frontend && npm run dev

# 3. Seed test data
npm run seed

# 4. Run tests
npm test
```

### Option 2: Full Docker Compose

Use this for CI or when you just want to run tests:

```bash
# Start all services in Docker
docker compose --profile compose up -d

# Seed test data
npm run seed

# Run tests
npm test
```

## 📦 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run setup` | Start database in Docker |
| `npm run seed` | Seed test data (auto-detects local vs Docker backend) |
| `npm test` | Run all E2E tests |
| `npm run test:ui` | Open Playwright UI mode |
| `npm run test:debug` | Run tests in debug mode |
| `npm run test:headed` | Run tests in headed mode (see browser) |
| `npm run test:report` | Open HTML test report |
| `npm run cleanup` | Stop all services and clean volumes |
| `npm run e2e` | Smart script that detects running services and runs tests |

## 🔄 Workflows

### Workflow 1: Active Development

When you're making changes to backend or frontend:

```bash
# Terminal 1: Database
docker compose up -d db

# Terminal 2: Backend
cd ../backend
npm run dev

# Terminal 3: Frontend
cd ../frontend
npm run dev

# Terminal 4: Tests (in tests-e2e/)
npm run seed  # First time or after schema changes
npm test      # Run tests
```

Benefits:
- ✅ Hot reload on code changes
- ✅ Fast feedback loop
- ✅ Can use debugger

### Workflow 2: Quick Test Run

When you just want to validate everything works:

```bash
# One command to rule them all
npm run e2e
```

This script:
1. Detects which services are running
2. Seeds data if needed
3. Runs tests
4. Shows results

### Workflow 3: Full Docker (CI-like)

When you want to test exactly like CI:

```bash
docker compose --profile compose up -d
npm run seed
npm test
npm run cleanup
```

## 🌱 Test Data

Test data is seeded via the backend's `app:seed:test` command.

### Re-seeding

Run `npm run seed` anytime you need fresh test data:
- After schema changes
- After test failures
- When starting a new test session

The seed script is **idempotent** - safe to run multiple times.

## 🎭 Playwright Configuration

Tests run on 5 browsers by default:
- Chromium (Desktop)
- Firefox (Desktop)
- WebKit (Desktop)
- Mobile Chrome
- Mobile Safari

### Run specific browser:

```bash
npx playwright test --project=chromium
```

### Run specific test file:

```bash
npx playwright test tests/folders.spec.ts
```

### Debug mode:

```bash
npm run test:debug
```

## 📊 Test Reports

After running tests:

```bash
npm run test:report
```

Opens an HTML report with:
- Test results
- Screenshots of failures
- Video recordings
- Network logs

## 🐛 Troubleshooting

### Tests timeout waiting for application

**Problem**: `Application not ready after 60 seconds`

**Solutions**:
1. Check services are running: `docker compose ps`
2. Check backend health: `curl http://localhost:8000/health`
3. Check frontend: `curl http://localhost:5173`
4. Restart services: `npm run cleanup && npm run setup`

### Database connection errors

**Problem**: `ECONNREFUSED localhost:5432`

**Solutions**:
1. Ensure database is running: `docker compose up -d db`
2. Wait for healthy status: `docker compose ps db`
3. Check logs: `docker compose logs db`

### No test data / tests skip

**Problem**: Tests skip with "No photos available"

**Solution**: Run seed command: `npm run seed`

### Port conflicts

**Problem**: `Port 5432 already in use`

**Solutions**:
1. Stop conflicting service
2. Or modify ports in `docker-compose.yml`

## 🔧 CI/CD

GitHub Actions workflow is provided in `.github/workflows/e2e.yml`.

The workflow:
1. Pulls backend/frontend Docker images
2. Starts services via Docker Compose
3. Seeds test data
4. Runs Playwright tests
5. Uploads reports as artifacts

### Triggering E2E tests from backend/frontend repos:

Use repository dispatch to trigger tests when images are updated:

```yaml
# In backend/.github/workflows/ci.yml
- name: Trigger E2E tests
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.PAT_TOKEN }}
    repository: YggdrasilCloud/tests-e2e
    event-type: run-e2e
    client-payload: |
      {
        "backend_version": "${{ github.sha }}",
        "frontend_version": "latest"
      }
```

## 📁 Project Structure

```
tests-e2e/
├── .github/workflows/      # GitHub Actions CI
├── scripts/                # Shell scripts
│   ├── setup.sh           # Initialize environment
│   ├── seed.sh            # Seed test data
│   └── run-tests.sh       # Smart test runner
├── tests/                  # Playwright tests
│   ├── folders.spec.ts
│   ├── photos.spec.ts
│   └── lightbox.spec.ts
├── fixtures/               # Test fixtures (photos, etc.)
├── docker-compose.yml      # Service definitions
├── playwright.config.ts    # Playwright configuration
├── global-setup.ts         # Test environment validation
└── package.json
```

## 🤝 Contributing

1. Add tests in `tests/` directory
2. Follow existing naming conventions: `*.spec.ts`
3. Use descriptive test names: `test('should ...')`
4. Always test on all browsers (default behavior)
5. Add fixtures in `fixtures/` if needed

## 📚 Resources

- [Playwright Documentation](https://playwright.dev/)
- [Backend Repository](https://github.com/YggdrasilCloud/backend)
- [Frontend Repository](https://github.com/YggdrasilCloud/frontend)
