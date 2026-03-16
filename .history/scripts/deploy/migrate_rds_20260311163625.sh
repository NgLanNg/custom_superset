#!/bin/bash
# migrate_rds.sh
# Applies DDL and seeds to the target postgres database defined in .env.production

set -e

ENV_FILE=".env.production"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "ERROR: $ENV_FILE not found. Please create it from .env.production.template"
    exit 1
fi

REQUIRED_VARS=("SUPERSET_DB_HOST" "SUPERSET_DB_PORT" "SUPERSET_DB_USER" "SUPERSET_DB_PASS" "SUPERSET_DB_NAME")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: $var is not set in $ENV_FILE"
        exit 1
    fi
done

# Build PostgreSQL connection string for psql
# If SSL is requested
export PGPASSWORD=$SUPERSET_DB_PASS

PSQL_ARGS="-h $SUPERSET_DB_HOST -p $SUPERSET_DB_PORT -U $SUPERSET_DB_USER -d $SUPERSET_DB_NAME"

if [ "$SUPERSET_DB_SSL" = "true" ] || [ "$SUPERSET_DB_SSL" = "1" ]; then
    if [ -n "$SUPERSET_DB_SSL_CERT_PATH" ]; then
        PSQL_ARGS="$PSQL_ARGS sslmode=verify-full sslrootcert=$SUPERSET_DB_SSL_CERT_PATH"
    else
        PSQL_ARGS="$PSQL_ARGS sslmode=require"
    fi
fi

echo "Connecting to RDS to apply DDLs..."

echo "1. Creating Equity Share table..."
psql $PSQL_ARGS -f scripts/init_db_script/create_scenario_table.sql
psql $PSQL_ARGS -f scripts/init_db_script/populate_scenario_data.sql

echo "2. Creating Growth Config table..."
psql $PSQL_ARGS -f scripts/init_db_script/create_growth_config_table.sql
psql $PSQL_ARGS -f scripts/init_db_script/populate_growth_config.sql

echo "3. Creating OPU Config table..."
psql $PSQL_ARGS -f scripts/init_db_script/create_opu_config_table.sql
psql $PSQL_ARGS -f scripts/init_db_script/populate_opu_config.sql

echo "4. Running dbt to create Staging and Gold models..."
cd dbt
# we need to pass the dbt variables via env vars
# dbt automatically uses POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_HOST, etc in our profiles.yml 
# wait, profiles.yml needs to be dynamic to support this!
export POSTGRES_USER=$SUPERSET_DB_USER
export POSTGRES_PASSWORD=$SUPERSET_DB_PASS
export POSTGRES_HOST=$SUPERSET_DB_HOST
export POSTGRES_PORT=$SUPERSET_DB_PORT
export POSTGRES_DB=$SUPERSET_DB_NAME

dbt build --profiles-dir .
cd ..

echo "5. Creating Tableau reporting view..."
psql $PSQL_ARGS -f scripts/init_db_script/create_tableau_view.sql

echo "Migration to RDS complete!"
