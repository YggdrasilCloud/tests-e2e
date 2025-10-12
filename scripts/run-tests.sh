#!/bin/bash
set -e

echo "🎭 Running E2E tests..."
echo ""

# Check if services are running
DB_RUNNING=$(docker compose ps db | grep -c "Up" || echo "0")
BACKEND_RUNNING=$(docker compose ps backend | grep -c "Up" || echo "0")
FRONTEND_RUNNING=$(docker compose ps frontend | grep -c "Up" || echo "0")

# Determine test mode
if [ "$DB_RUNNING" = "1" ] && [ "$BACKEND_RUNNING" = "1" ] && [ "$FRONTEND_RUNNING" = "1" ]; then
    echo "📦 Mode: Full Docker Compose"
    MODE="compose"
elif [ "$DB_RUNNING" = "1" ]; then
    echo "💻 Mode: Local backend/frontend + Docker DB"
    MODE="local"
else
    echo "❌ No services running. Please start them first:"
    echo ""
    echo "Option 1 - Docker Compose (full stack):"
    echo "  docker compose --profile compose up -d"
    echo ""
    echo "Option 2 - Local development:"
    echo "  docker compose up -d db"
    echo "  cd ../backend && npm run dev"
    echo "  cd ../frontend && npm run dev"
    echo ""
    exit 1
fi

# Check if seed is needed
echo "🌱 Checking test data..."
./scripts/seed.sh

# Run Playwright tests
echo ""
echo "🎬 Running Playwright tests..."

if [ "$MODE" = "compose" ]; then
    # Use BASE_URL pointing to Docker service
    BASE_URL=http://localhost:5173 npx playwright test "$@"
else
    # Use BASE_URL pointing to local dev server
    BASE_URL=http://localhost:5173 npx playwright test "$@"
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
else
    echo ""
    echo "❌ Some tests failed. View the report with: npm run test:report"
fi

exit $EXIT_CODE
