#!/bin/bash
set -e

echo "Starting Superset with custom plugin..."

# Set config path if not already set
export SUPERSET_CONFIG_PATH="${SUPERSET_CONFIG_PATH:-/app/superset_config.py}"
export PYTHONPATH="${PYTHONPATH:-/app}"

# Run database migrations
echo "Running database migrations..."
superset db upgrade || echo "Migrations may already be applied"

# Initialize roles and permissions
echo "Initializing Superset..."
superset init || echo "Initial setup may already be complete"

# Start the Superset development server
exec superset run -p 8088 --host=0.0.0.0 --with-threads
