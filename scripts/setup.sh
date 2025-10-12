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

# Start all services (DB, Backend, Frontend)
echo "📦 Starting services (DB, Backend, Frontend)..."
docker compose up -d

# Wait for all services to be healthy
echo "⏳ Waiting for services to be healthy..."
timeout 120 bash -c 'until docker compose ps | grep -q "backend.*healthy" && docker compose ps | grep -q "frontend.*Up"; do echo "  Still waiting..."; sleep 2; done' || {
    echo "❌ Services failed to start"
    echo ""
    echo "Check logs with:"
    echo "  docker compose logs db"
    echo "  docker compose logs backend"
    echo "  docker compose logs frontend"
    exit 1
}

echo "✅ All services are ready!"
echo ""
echo "Services running:"
echo "  - Database:  postgresql://test:test@localhost:5432/yggdrasil_test"
echo "  - Backend:   http://localhost:8000"
echo "  - Frontend:  http://localhost:5173"
echo ""
echo "Next steps:"
echo "  1. Seed test data:  npm run seed"
echo "  2. Run tests:       npm test"
echo ""
echo "View logs:"
echo "  docker compose logs -f"
