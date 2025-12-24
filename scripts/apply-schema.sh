#!/bin/bash
# PostgreSQL Schema Setup Script
# Applies the database schema before seeding

# Default configuration (can be overridden by environment variables)
CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-postgres}"
DBNAME="${PGDATABASE:-soldata}"
DBUSER="${PGUSER:-postgres}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/../db/pgsql/schema.sql"

echo "[INFO] Applying PostgreSQL schema..."
echo "[INFO] Database: $DBNAME"
echo "[INFO] User: $DBUSER"
echo "[INFO] Schema file: $SCHEMA_FILE"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "[ERROR] Schema file not found: $SCHEMA_FILE"
    exit 1
fi

# Detect container runtime (Podman or Docker)
if command -v podman >/dev/null 2>&1 && podman ps --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    CONTAINER_CMD="podman"
elif command -v docker >/dev/null 2>&1 && docker ps --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    CONTAINER_CMD="docker"
else
    echo "[ERROR] No running container found:  $CONTAINER_NAME"
    echo "[ERROR] Please start the PostgreSQL container first"
    exit 1
fi

echo "[INFO] Using container: $CONTAINER_NAME (runtime: $CONTAINER_CMD)"

# Apply schema using psql inside the container
$CONTAINER_CMD exec -i "$CONTAINER_NAME" psql -U "$DBUSER" -d "$DBNAME" < "$SCHEMA_FILE" || {
    echo "[ERROR] Failed to apply schema"
    exit 1
}

echo "[SUCCESS] Schema applied successfully"
