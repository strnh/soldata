#!/bin/bash
set -e

# PostgreSQL Connection Readiness Check Utility
# Waits for PostgreSQL to be ready to accept connections

# Default configuration
PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGDATABASE="${PGDATABASE:-soldata}"
TIMEOUT="${POSTGRES_TIMEOUT:-60}"

# Logging functions
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_success() {
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

# Check if PostgreSQL is ready

check_postgres() {
    # Check if we're using Podman/Docker container
    if command -v podman >/dev/null 2>&1 && podman ps --filter "name=^${POSTGRES_CONTAINER_NAME:-postgres}$" --format "{{.Names}}" | grep -q "^${POSTGRES_CONTAINER_NAME:-postgres}$"; then
        # Use pg_isready inside the container
        podman exec "${POSTGRES_CONTAINER_NAME:-postgres}" pg_isready -U "$PGUSER" -d "$PGDATABASE" >/dev/null 2>&1
        return $?
    elif command -v docker >/dev/null 2>&1 && docker ps --filter "name=^${POSTGRES_CONTAINER_NAME:-postgres}$" --format "{{.Names}}" | grep -q "^${POSTGRES_CONTAINER_NAME:-postgres}$"; then
        # Use pg_isready inside the Docker container
        docker exec "${POSTGRES_CONTAINER_NAME:-postgres}" pg_isready -U "$PGUSER" -d "$PGDATABASE" >/dev/null 2>&1
        return $?
    elif command -v pg_isready >/dev/null 2>&1; then
        # Fallback to host pg_isready if available
        pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" >/dev/null 2>&1
        return $?
    else
        # Last resort: try psql on host
        PGPASSWORD="${PGPASSWORD:-postgres}" psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT 1" >/dev/null 2>&1
        return $?
    fi
}

# Wait for PostgreSQL with timeout
wait_for_postgres() {
    local elapsed=0
    local interval=2
    
    log_info "Waiting for PostgreSQL at $PGHOST:$PGPORT (timeout: ${TIMEOUT}s)..."
    log_info "Database: $PGDATABASE, User: $PGUSER"
    
    while [ $elapsed -lt $TIMEOUT ]; do
        if check_postgres; then
            log_success "PostgreSQL is ready!"
            return 0
        fi
        
        log_info "PostgreSQL not ready yet (${elapsed}s/${TIMEOUT}s), waiting..."
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    log_error "Timeout waiting for PostgreSQL after ${TIMEOUT}s"
    return 1
}

# Show usage
show_usage() {
    cat <<EOF
Usage: $0 [options]

Wait for PostgreSQL to be ready to accept connections.

Environment Variables:
    PGHOST              PostgreSQL host (default: 127.0.0.1)
    PGPORT              PostgreSQL port (default: 5432)
    PGUSER              PostgreSQL user (default: postgres)
    PGPASSWORD          PostgreSQL password (default: postgres)
    PGDATABASE          Database name (default: soldata)
    POSTGRES_TIMEOUT    Timeout in seconds (default: 60)

Examples:
    $0
    PGHOST=localhost PGPORT=5433 $0
    POSTGRES_TIMEOUT=120 $0

EOF
}

# Main
main() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_usage
        exit 0
    fi
    
    wait_for_postgres
    exit $?
}

main "$@"
