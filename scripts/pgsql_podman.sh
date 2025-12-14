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
    
    if container_exists; then
        log_info "Container '$CONTAINER_NAME' exists but is stopped, removing it..."
        podman rm "$CONTAINER_NAME" || {
            log_error "Failed to remove existing container"
            return 1
        }
    fi
    
    log_info "Creating and starting container '$CONTAINER_NAME'..."
    log_info "  Image: $POSTGRES_IMAGE"
    log_info "  Database: $POSTGRES_DB"
    log_info "  User: $POSTGRES_USER"
    log_info "  Port: $POSTGRES_PORT"
    log_info "  Volume: $VOLUME_NAME"
    
    podman run --replace -d \
        --name "$CONTAINER_NAME" \
        --network=host \
        -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        -e POSTGRES_DB="$POSTGRES_DB" \
        -e POSTGRES_USER="$POSTGRES_USER" \
        -v "${VOLUME_NAME}:/var/lib/postgresql" \
        "$POSTGRES_IMAGE" || {
        log_error "Failed to start container"
        return 1
    }
    
    log_success "Container started successfully"
    
    # Wait for PostgreSQL to be ready
    if ! wait_for_postgres; then
        log_error "Container started but PostgreSQL is not ready"
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
