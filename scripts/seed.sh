#!/bin/bash
set -e

echo "🌱 Seeding test data..."

# Check if database is running
if ! docker compose ps db | grep -q "Up"; then
    echo "❌ Database is not running. Start it with: docker compose up -d db"
    exit 1
fi

# Check if we should use Docker or local backend
if docker compose ps backend | grep -q "Up"; then
    # Backend is running in Docker
    echo "   Using backend from Docker Compose..."
    docker compose run --rm seed
else
    # Assume backend is running locally
    echo "   Using local backend..."

    # Check if backend directory exists
    if [ ! -d "../backend" ]; then
        echo "❌ Backend directory not found at ../backend"
        echo "   Make sure you're running this from the tests-e2e directory"
        exit 1
    fi

    # Run seed command in backend
    cd ../backend

    if [ -f "composer.json" ]; then
        # Symfony backend
        php bin/console app:seed:test
    elif [ -f "package.json" ]; then
        # Node backend
        npm run seed:test
    else
        echo "❌ Unknown backend type"
        exit 1
    fi

    cd - > /dev/null
fi

echo "✅ Test data seeded successfully!"
