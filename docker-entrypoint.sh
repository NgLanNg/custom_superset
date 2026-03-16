#!/bin/bash
set -e

echo "Starting Superset with custom configuration..."

# Run database migrations
superset db upgrade

# Create default roles and permissions
superset init

# Load example data if needed
if [ "${LOAD_EXAMPLES:-false}" = "true" ]; then
    superset load_examples
fi

# Generate FAB metadata (custom views)
echo "Registering custom views..."

# Start the Superset development server
exec superset run -p 8088 --host=0.0.0.0 --with-threads --reload --debugger
