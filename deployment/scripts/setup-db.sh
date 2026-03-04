#!/bin/bash
# Setup database: create extensions, run schema, apply migrations
set -euo pipefail

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USERNAME:-postgres}
DB_PASS=${DB_PASSWORD:-password}
DB_NAME=${DB_DATABASE:-agriprice}

export PGPASSWORD=$DB_PASS

echo "==> Waiting for PostgreSQL to be ready..."
until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER 2>/dev/null; do
  sleep 2
done

echo "==> Creating database (if not exists)..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME"

echo "==> Enabling PostGIS extension..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS postgis;"

echo "==> Running schema..."
if [ -f ../backend/database/schema.sql ]; then
  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f ../backend/database/schema.sql
fi

echo "==> Database setup complete!"