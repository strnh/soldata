#!/bin/bash
# PostgreSQL Schema Setup Script
# Applies the database schema before seeding

# Default configuration (can be overridden by environment variables)
PSQL="${PSQL:-/usr/bin/psql}"
DBNAME="${PGDATABASE:-soldata}"
DBHOST="${PGHOST:-127.0.0.1}"
DBPORT="${PGPORT:-5432}"
DBUSER="${PGUSER:-postgres}"

# Set password from environment
if [ -n "$PGPASSWORD" ]; then
    export PGPASSWORD
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/../db/pgsql/schema.sql"

echo "[INFO] Applying PostgreSQL schema..."
echo "[INFO] Database: $DBNAME at $DBHOST:$DBPORT"
echo "[INFO] User: $DBUSER"
echo "[INFO] Schema file: $SCHEMA_FILE"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "[ERROR] Schema file not found: $SCHEMA_FILE"
    exit 1
fi

$PSQL -U "$DBUSER" -h "$DBHOST" -p "$DBPORT" "$DBNAME" < "$SCHEMA_FILE" || {
    echo "[ERROR] Failed to apply schema"
    exit 1
}

echo "[SUCCESS] Schema applied successfully"
