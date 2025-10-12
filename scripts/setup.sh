#!/bin/bash
set -e

echo "🚀 Setting up E2E test environment..."

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Cleanup any existing containers
echo "🧹 Cleaning up existing containers..."
docker compose down -v 2>/dev/null || true

# Start database
echo "📦 Starting database..."
docker compose up -d db

# Wait for database to be healthy
echo "⏳ Waiting for database..."
timeout 30 bash -c 'until docker compose ps db | grep -q "healthy"; do sleep 1; done' || {
    echo "❌ Database failed to start"
    exit 1
}

echo "✅ Database is ready!"
echo ""
echo "Next steps:"
echo "  1. Start your backend:  cd ../backend && npm run dev"
echo "  2. Start your frontend: cd ../frontend && npm run dev"
echo "  3. Seed test data:      npm run seed"
echo "  4. Run tests:           npm test"
echo ""
echo "Or use Docker Compose for everything:"
echo "  docker compose --profile compose up -d"
echo "  npm run seed"
echo "  npm test"
