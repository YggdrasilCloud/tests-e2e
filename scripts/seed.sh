#!/bin/bash
set -e

echo "🌱 Seeding test data..."

# Check if backend is running
if ! docker compose ps backend | grep -q "Up"; then
    echo "❌ Backend is not running. Start services with: npm run setup"
    exit 1
fi

# Run seed command directly in backend container (avoid container recreation)
echo "   Running seed command in backend container..."
docker compose exec -T backend php bin/console app:seed:test

echo "✅ Test data seeded successfully!"
