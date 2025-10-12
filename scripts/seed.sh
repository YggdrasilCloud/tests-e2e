#!/bin/bash
set -e

echo "🌱 Seeding test data..."

# Check if backend is running
if ! docker compose ps backend | grep -q "Up"; then
    echo "❌ Backend is not running. Start services with: npm run setup"
    exit 1
fi

# Run seed command in backend container
echo "   Running seed command in backend container..."
docker compose run --rm seed

echo "✅ Test data seeded successfully!"
