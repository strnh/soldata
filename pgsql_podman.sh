#!/bin/sh
# Legacy script - redirects to the new improved version
# For the improved version with more features, use: scripts/pgsql_podman.sh

echo "NOTE: This is the legacy script. Redirecting to scripts/pgsql_podman.sh"
echo "For more options, run: bash scripts/pgsql_podman.sh --help"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$SCRIPT_DIR/scripts/pgsql_podman.sh" start
 
