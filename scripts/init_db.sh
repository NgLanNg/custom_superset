#!/bin/bash
# Initialize PostgreSQL for local Superset development.
# Requires: podman-compose (or docker compose) running the postgres service.
set -euo pipefail

DASHBOARD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SUPERSET_DIR="$DASHBOARD_ROOT/superset"
SCRIPTS_DIR="$DASHBOARD_ROOT/scripts/init_db_script"

echo "==> Starting PostgreSQL container..."
cd "$DASHBOARD_ROOT"
podman compose up -d postgres
sleep 3

echo "==> Waiting for PostgreSQL to be healthy..."
for i in $(seq 1 20); do
  if podman exec superset-postgres pg_isready -U superset > /dev/null 2>&1; then
    echo "    PostgreSQL is ready."
    break
  fi
  if [ "$i" -eq 20 ]; then
    echo "    ERROR: PostgreSQL did not start in time."
    exit 1
  fi
  sleep 1
done

echo "==> Running Superset DB migrations..."
cd "$SUPERSET_DIR"
export FLASK_APP=superset
export SUPERSET_SECRET_KEY="${SUPERSET_SECRET_KEY:-TEST}"
export SUPERSET__SQLALCHEMY_DATABASE_URI="postgresql+psycopg2://superset:superset@localhost:5432/superset"
./.venv/bin/superset db upgrade

echo "==> Creating scenario table..."
podman exec -i superset-postgres psql -U superset -d superset < "$SCRIPTS_DIR/create_scenario_table.sql"

echo "==> Loading seed data..."
podman exec -i superset-postgres psql -U superset -d superset < "$SCRIPTS_DIR/populate_scenario_data.sql"

echo "==> Creating default admin user (admin/admin)..."
./.venv/bin/superset fab create-admin \
  --username admin \
  --firstname Admin \
  --lastname User \
  --email admin@example.com \
  --password admin 2>/dev/null || echo "    Admin user already exists."

echo "==> Initializing roles and permissions..."
./.venv/bin/superset init

echo "==> Registering PostgreSQL database connection and scenario dataset..."
./.venv/bin/python -c "
from superset.app import create_app
app = create_app()
with app.app_context():
    from superset.extensions import db
    from superset.models.core import Database
    from superset.connectors.sqla.models import SqlaTable

    pg_uri = 'postgresql+psycopg2://superset:superset@localhost:5432/superset'
    pg_db = db.session.query(Database).filter_by(database_name='PostgreSQL').first()
    if not pg_db:
        pg_db = Database(
            database_name='PostgreSQL',
            sqlalchemy_uri=pg_uri,
            expose_in_sqllab=True,
            allow_run_async=False,
            allow_dml=True,
        )
        db.session.add(pg_db)
        db.session.commit()

    ds = db.session.query(SqlaTable).filter_by(
        table_name='silver_scenario_equity_share', database_id=pg_db.id
    ).first()
    if not ds:
        ds = SqlaTable(
            table_name='silver_scenario_equity_share',
            database_id=pg_db.id,
            schema='public',
        )
        db.session.add(ds)
        db.session.commit()

    print(f'    Database: id={pg_db.id}, Dataset: id={ds.id}')
"

echo "==> Done. PostgreSQL is ready for Superset."
echo "    Connection: postgresql+psycopg2://superset:superset@localhost:5432/superset"
