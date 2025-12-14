#!/bin/bash
set -e

# PostgreSQL Podman Container Management Script
# This script manages a PostgreSQL container using Podman for development and CI/CD

# Default configuration (can be overridden by environment variables)
CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-soldata}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
VOLUME_NAME="${POSTGRES_VOLUME:-pgdata}"
POSTGRES_IMAGE="${POSTGRES_IMAGE:-docker.io/library/postgres:latest}"

# PostgreSQL 18+ requires explicit PGDATA path
PGDATA_PATH="/var/lib/postgresql/data/pgdata"

# Determine data directory path
# In CI (GitHub Actions), use ephemeral directory with unique run ID
# Otherwise, use named volume for persistent data
if [ -n "${RUNNER_TEMP:-}" ] && [ -n "${GITHUB_RUN_ID:-}" ]; then
    DATA_DIR="${RUNNER_TEMP}/pgdata-${GITHUB_RUN_ID}"
    USE_VOLUME=false
else
    DATA_DIR=""
    USE_VOLUME=true
fi

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

# Clean up stale containers, volumes, and data directories
cleanup_stale_resources() {
    log_info "Cleaning up stale resources..."
    
    # Remove stale container
    if container_exists; then
        log_info "Removing stale container '$CONTAINER_NAME'..."
        podman rm -f "$CONTAINER_NAME" 2>/dev/null || true
    fi
    
    # Remove stale volume if using volumes
    if [ "$USE_VOLUME" = true ]; then
        if podman volume exists "$VOLUME_NAME" 2>/dev/null; then
            log_info "Removing stale volume '$VOLUME_NAME'..."
            podman volume rm "$VOLUME_NAME" 2>/dev/null || true
        fi
    fi
    
    # Remove stale data directory if using ephemeral directory
    if [ "$USE_VOLUME" = false ] && [ -n "$DATA_DIR" ]; then
        if [ -d "$DATA_DIR" ]; then
            log_info "Removing stale data directory '$DATA_DIR'..."
            # Try regular rm first, then use sudo if needed (for container-created files)
            if ! rm -rf "$DATA_DIR" 2>/dev/null; then
                if command -v sudo >/dev/null 2>&1; then
                    sudo rm -rf "$DATA_DIR" 2>/dev/null || true
                fi
            fi
        fi
    fi
    
    log_success "Cleanup completed"
}

# Check if container is running
is_container_running() {
    podman ps --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

# Check if container exists (running or stopped)
container_exists() {
    podman ps -a --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    local max_attempts=30
    local attempt=1
    
    log_info "Waiting for PostgreSQL to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if podman exec "$CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
            log_success "PostgreSQL is ready!"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - PostgreSQL not ready yet, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "PostgreSQL failed to become ready after $max_attempts attempts"
    return 1
}

# Start PostgreSQL container
start_container() {
    log_info "Starting PostgreSQL container..."
    
    if is_container_running; then
        log_info "Container '$CONTAINER_NAME' is already running"
        wait_for_postgres
        return 0
    fi
    
    # Clean up any stale resources before starting
    cleanup_stale_resources
    
    log_info "Creating and starting container '$CONTAINER_NAME'..."
    log_info "  Image: $POSTGRES_IMAGE"
    log_info "  Database: $POSTGRES_DB"
    log_info "  User: $POSTGRES_USER"
    log_info "  Port: $POSTGRES_PORT"
    log_info "  PGDATA: $PGDATA_PATH"
    
    # Prepare volume mount argument
    local volume_arg
    if [ "$USE_VOLUME" = true ]; then
        # Use named volume for persistent data
        log_info "  Volume: $VOLUME_NAME"
        volume_arg="-v ${VOLUME_NAME}:/var/lib/postgresql/data:Z"
    else
        # Use ephemeral directory for CI/testing
        log_info "  Data directory: $DATA_DIR"
        mkdir -p "$DATA_DIR"
        volume_arg="-v ${DATA_DIR}:/var/lib/postgresql/data:Z"
    fi
    
    podman run --replace -d \
        --name "$CONTAINER_NAME" \
        -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        -e POSTGRES_DB="$POSTGRES_DB" \
        -e POSTGRES_USER="$POSTGRES_USER" \
        -e PGDATA="$PGDATA_PATH" \
        -p "${POSTGRES_PORT}:5432" \
        $volume_arg \
        "$POSTGRES_IMAGE" || {
        log_error "Failed to start container"
        return 1
    }
    
    log_success "Container started successfully"
    
    # Wait for PostgreSQL to be ready
    if ! wait_for_postgres; then
        log_error "Container started but PostgreSQL is not ready"
        podman logs "$CONTAINER_NAME" || true
        return 1
    fi
    
    return 0
}

# Stop and optionally clean up PostgreSQL container
stop_container() {
    local remove_volume=false
    
    if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
        remove_volume=true
    fi
    
    log_info "Stopping PostgreSQL container..."
    
    if ! container_exists; then
        log_info "Container '$CONTAINER_NAME' does not exist"
        return 0
    fi
    
    if is_container_running; then
        log_info "Stopping container '$CONTAINER_NAME'..."
        podman stop "$CONTAINER_NAME" || {
            log_error "Failed to stop container"
            return 1
        }
        log_success "Container stopped"
    else
        log_info "Container '$CONTAINER_NAME' is not running"
    fi
    
    log_info "Removing container '$CONTAINER_NAME'..."
    podman rm "$CONTAINER_NAME" || {
        log_error "Failed to remove container"
        return 1
    }
    log_success "Container removed"
    
    if [ "$remove_volume" = true ]; then
        if [ "$USE_VOLUME" = true ]; then
            log_info "Removing volume '$VOLUME_NAME'..."
            if podman volume exists "$VOLUME_NAME" 2>/dev/null; then
                podman volume rm "$VOLUME_NAME" || {
                    log_error "Failed to remove volume"
                    return 1
                }
                log_success "Volume removed"
            else
                log_info "Volume '$VOLUME_NAME' does not exist"
            fi
        else
            # Remove ephemeral data directory
            if [ -n "$DATA_DIR" ] && [ -d "$DATA_DIR" ]; then
                log_info "Removing data directory '$DATA_DIR'..."
                # Try regular rm first, then use sudo if needed (for container-created files)
                if ! rm -rf "$DATA_DIR" 2>/dev/null; then
                    if command -v sudo >/dev/null 2>&1; then
                        sudo rm -rf "$DATA_DIR" || {
                            log_error "Failed to remove data directory"
                            return 1
                        }
                    else
                        log_error "Failed to remove data directory (permission denied and sudo not available)"
                        return 1
                    fi
                fi
                log_success "Data directory removed"
            else
                log_info "Data directory does not exist or not configured"
            fi
        fi
    fi
    
    return 0
}

# Show container status
show_status() {
    log_info "Container status:"
    if is_container_running; then
        echo "Status: Running"
        podman ps --filter "name=^${CONTAINER_NAME}$"
    elif container_exists; then
        echo "Status: Stopped"
        podman ps -a --filter "name=^${CONTAINER_NAME}$"
    else
        echo "Status: Not created"
    fi
}

# Show usage information
show_usage() {
    cat <<EOF
Usage: $0 {start|stop|status} [options]

Commands:
    start       Start PostgreSQL container with readiness check
    stop        Stop and remove container
                Options:
                  --clean, -c    Also remove the volume
    status      Show container status

Environment Variables:
    POSTGRES_CONTAINER_NAME    Container name (default: postgres)
    POSTGRES_PASSWORD          PostgreSQL password (default: postgres)
    POSTGRES_DB                Database name (default: soldata)
    POSTGRES_USER              PostgreSQL user (default: postgres)
    POSTGRES_PORT              Host port mapping (default: 5432)
    POSTGRES_VOLUME            Volume name (default: pgdata)
    POSTGRES_IMAGE             Docker image (default: docker.io/library/postgres:latest)

Examples:
    $0 start
    $0 stop --clean
    POSTGRES_PORT=5433 $0 start

EOF
}

# Main script logic
main() {
    case "${1:-}" in
        start)
            start_container
            exit $?
            ;;
        stop)
            stop_container "$2"
            exit $?
            ;;
        status)
            show_status
            exit 0
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "Invalid command: ${1:-}"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
