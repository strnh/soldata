#!/bin/sh
# PostgreSQL Seed Script
# Uses psql inside the container for better portability

# Default configuration
CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-postgres}"
DBNAME="${PGDATABASE:-soldata}"
DBUSER="${PGUSER:-postgres}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Running seed scripts..."
echo "[INFO] Database: $DBNAME"
echo "[INFO] User: $DBUSER"

# Detect container runtime (Podman or Docker)
if command -v podman >/dev/null 2>&1 && podman ps --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    CONTAINER_CMD="podman"
elif command -v docker >/dev/null 2>&1 && docker ps --filter "name=^${CONTAINER_NAME}$" --format "{{. Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    CONTAINER_CMD="docker"
else
    echo "[ERROR] No running container found:  $CONTAINER_NAME"
    echo "[ERROR] Please start the PostgreSQL container first"
    exit 1
fi

echo "[INFO] Using container: $CONTAINER_NAME (runtime: $CONTAINER_CMD)"

# Run seed scripts
$CONTAINER_CMD exec -i "$CONTAINER_NAME" psql -U "$DBUSER" -d "$DBNAME" < "$SCRIPT_DIR/soldata_seed.sql" || {
    echo "[ERROR] Failed to run soldata_seed.sql"
    exit 1
}
echo "[SUCCESS] soldata_seed.sql completed"

$CONTAINER_CMD exec -i "$CONTAINER_NAME" psql -U "$DBUSER" -d "$DBNAME" < "$SCRIPT_DIR/employee_seed.sql" || {
    echo "[ERROR] Failed to run employee_seed.sql"
    exit 1
}
echo "[SUCCESS] employee_seed.sql completed"

echo "[SUCCESS] All seed scripts completed successfully"
