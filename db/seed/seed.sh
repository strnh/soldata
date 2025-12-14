#!/bin/sh
# PostgreSQL Seed Script
# This script supports both environment variables and .pass file authentication

# Default configuration (can be overridden by environment variables)
PSQL="${PSQL:-/usr/bin/psql}"
DBNAME="${PGDATABASE:-soldata}"
DBHOST="${PGHOST:-127.0.0.1}"
DBPORT="${PGPORT:-5432}"
DBUSER="${PGUSER:-postgres}"

# Set password from environment or use .pass file
if [ -n "$PGPASSWORD" ]; then
    export PGPASSWORD
else
    # Fallback to .pass file if it exists
    if [ -f './.pass' ]; then
        export PGPASSFILE='./.pass'
    fi
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Running seed scripts..."
echo "[INFO] Database: $DBNAME at $DBHOST:$DBPORT"
echo "[INFO] User: $DBUSER"

# Run seed scripts
$PSQL -U "$DBUSER" -h "$DBHOST" -p "$DBPORT" "$DBNAME" < "$SCRIPT_DIR/soldata_seed.sql" || {
    echo "[ERROR] Failed to run soldata_seed.sql"
    exit 1
}
echo "[SUCCESS] soldata_seed.sql completed"

$PSQL -U "$DBUSER" -h "$DBHOST" -p "$DBPORT" "$DBNAME" < "$SCRIPT_DIR/employee_seed.sql" || {
    echo "[ERROR] Failed to run employee_seed.sql"
    exit 1
}
echo "[SUCCESS] employee_seed.sql completed"

echo "[SUCCESS] All seed scripts completed successfully"
