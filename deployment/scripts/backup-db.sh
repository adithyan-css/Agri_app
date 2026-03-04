#!/bin/bash
# Backup PostgreSQL database to a timestamped file
set -euo pipefail

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USERNAME:-postgres}
DB_PASS=${DB_PASSWORD:-password}
DB_NAME=${DB_DATABASE:-agriprice}
BACKUP_DIR=${BACKUP_DIR:-./backups}

export PGPASSWORD=$DB_PASS

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p $BACKUP_DIR

echo "==> Backing up $DB_NAME to $BACKUP_FILE..."
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME | gzip > $BACKUP_FILE

echo "==> Backup complete: $BACKUP_FILE ($(du -h $BACKUP_FILE | cut -f1))"

# Keep only last 7 backups
ls -tp ${BACKUP_DIR}/${DB_NAME}_*.sql.gz 2>/dev/null | tail -n +8 | xargs -I {} rm -- {} 2>/dev/null || true
echo "==> Cleanup complete (keeping last 7 backups)"