#!/bin/bash
set -e

echo "🌱 Seeding test data..."

# Check if backend is running
if ! docker compose ps backend | grep -q "Up"; then
    echo "❌ Backend is not running. Start services with: npm run setup"
    exit 1
fi

# Run seed command as www-data to ensure correct file ownership
# The backend container runs as root but FrankenPHP runs as www-data
echo "   Running seed command in backend container (as www-data)..."
docker compose exec -T backend su -s /bin/sh www-data -c 'php bin/console app:seed:test'

# Fix permissions on storage directory to ensure www-data can write
echo "   Fixing storage permissions..."
docker compose exec -T backend chmod -R 0777 /app/var/storage

echo "✅ Test data seeded successfully!"
