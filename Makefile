.PHONY: help db-start db-stop db-seed db-schema db-recreate db-status

# Default PostgreSQL configuration (can be overridden)
POSTGRES_CONTAINER_NAME ?= postgres
POSTGRES_PASSWORD ?= postgres
POSTGRES_DB ?= soldata
POSTGRES_USER ?= postgres
POSTGRES_PORT ?= 5432

# Script paths
SCRIPT_DIR = scripts
PODMAN_SCRIPT = $(SCRIPT_DIR)/pgsql_podman.sh
WAIT_SCRIPT = $(SCRIPT_DIR)/wait-for-postgres.sh
SCHEMA_SCRIPT = $(SCRIPT_DIR)/apply-schema.sh
SEED_SCRIPT = db/seed/seed.sh

# Export environment variables for scripts
export POSTGRES_CONTAINER_NAME
export POSTGRES_PASSWORD
export POSTGRES_DB
export POSTGRES_USER
export POSTGRES_PORT
export PGHOST = 127.0.0.1
export PGPORT = $(POSTGRES_PORT)
export PGUSER = $(POSTGRES_USER)
export PGPASSWORD = $(POSTGRES_PASSWORD)
export PGDATABASE = $(POSTGRES_DB)

help: ## Show this help message
	@echo "PostgreSQL Database Management Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment Variables:"
	@echo "  POSTGRES_CONTAINER_NAME  Container name (default: postgres)"
	@echo "  POSTGRES_PASSWORD        PostgreSQL password (default: postgres)"
	@echo "  POSTGRES_DB              Database name (default: soldata)"
	@echo "  POSTGRES_USER            PostgreSQL user (default: postgres)"
	@echo "  POSTGRES_PORT            Host port mapping (default: 5432)"

db-start: ## Start PostgreSQL container with Podman
	@echo "Starting PostgreSQL container..."
	@bash $(PODMAN_SCRIPT) start

db-stop: ## Stop PostgreSQL container
	@echo "Stopping PostgreSQL container..."
	@bash $(PODMAN_SCRIPT) stop

db-stop-clean: ## Stop PostgreSQL container and remove volume
	@echo "Stopping PostgreSQL container and cleaning up..."
	@bash $(PODMAN_SCRIPT) stop --clean

db-schema: ## Apply database schema (requires running database)
	@echo "Applying database schema..."
	@bash $(WAIT_SCRIPT)
	@bash $(SCHEMA_SCRIPT)

db-seed: ## Run database seed scripts (requires running database with schema)
	@echo "Running database seed scripts..."
	@bash $(WAIT_SCRIPT)
	@bash $(SEED_SCRIPT)

db-status: ## Show database container status
	@bash $(PODMAN_SCRIPT) status

db-init: db-schema db-seed ## Initialize database (apply schema and seed)
	@echo "Database initialized successfully!"

db-recreate: db-stop db-start db-init ## Recreate database (stop, start, schema, seed)
	@echo "Database recreated successfully!"

db-recreate-clean: db-stop-clean db-start db-init ## Recreate database with clean volumes
	@echo "Database recreated with clean volumes successfully!"
