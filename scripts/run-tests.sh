#!/bin/bash
set -e

echo "🎭 Running E2E tests..."
echo ""

# Check if services are running
if ! docker compose ps backend | grep -q "Up" || ! docker compose ps frontend | grep -q "Up"; then
    echo "❌ Services are not running. Start them with: npm run setup"
    echo ""
    echo "Current status:"
    docker compose ps
    exit 1
fi

echo "✅ Services are running"
echo ""

# Run Playwright tests
echo "🎬 Running Playwright tests..."
BASE_URL=http://localhost:5173 npx playwright test "$@"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
else
    echo ""
    echo "❌ Some tests failed. View the report with: npm run test:report"
fi

exit $EXIT_CODE
