#!/bin/bash
# Seed the database with initial data via the NestJS backend
set -euo pipefail

BACKEND_URL=${BACKEND_URL:-http://localhost:3000}

echo "==> Waiting for backend to be ready..."
until curl -sf ${BACKEND_URL}/api/v1/health >/dev/null 2>&1; do
  echo "    Backend not ready, retrying in 5s..."
  sleep 5
done

echo "==> Triggering seed via backend API..."
curl -sf -X POST ${BACKEND_URL}/api/v1/seed/run | jq . 2>/dev/null || echo "Seed response received"

echo "==> Seeding complete!"