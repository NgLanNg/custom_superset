#!/bin/bash
# Dashboard root is needed in PYTHONPATH so `import superset_config` resolves.
# The .venv's editable install (.pth file) already points Python at
# superset/superset/ for the `superset` package — do NOT add the git repo root
# (superset/) to PYTHONPATH, as that shadows the package with the repo root dir.
DASHBOARD_ROOT="$(cd "$(dirname "$0")" && pwd)"
SUPERSET_DIR="$DASHBOARD_ROOT/superset"

export FLASK_APP="superset"
export FLASK_ENV="development"
export SUPERSET_SECRET_KEY="${SUPERSET_SECRET_KEY:-A_VERY_SECURE_RANDOM_KEY}"
export PYTHONPATH="$DASHBOARD_ROOT"
unset SUPERSET_CONFIG   # Clear any stale test config from pytest sessions

# Backend — uses .venv which already has superset installed in editable mode
osascript -e "tell application \"Terminal\" to do script \"cd '$SUPERSET_DIR' && export FLASK_APP=superset && export FLASK_ENV=development && export SUPERSET_SECRET_KEY=TEST && export PYTHONPATH='$DASHBOARD_ROOT' && unset SUPERSET_CONFIG && ./.venv/bin/superset run -p 8088 --with-threads --reload --debugger\""

# Frontend webpack dev server
osascript -e "tell application \"Terminal\" to do script \"cd '$SUPERSET_DIR/superset-frontend' && npm run dev-server\""

