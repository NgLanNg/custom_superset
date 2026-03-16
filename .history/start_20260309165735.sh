#!/bin/bash
# superset_config.py is symlinked into superset/ so Python finds it naturally
# when run from that directory. Do NOT set PYTHONPATH to the dashboard root —
# it causes `import superset` to resolve to the git repo directory (a namespace
# package), shadowing the editable .venv install.
DASHBOARD_ROOT="$(cd "$(dirname "$0")" && pwd)"
SUPERSET_DIR="$DASHBOARD_ROOT/superset"

# Ensure the symlink exists (idempotent)
ln -sf "$DASHBOARD_ROOT/superset_config.py" "$SUPERSET_DIR/superset_config.py"

# Backend — run from superset/ with no PYTHONPATH override
osascript -e "tell application \"Terminal\" to do script \"cd '$SUPERSET_DIR' && unset SUPERSET_CONFIG && unset PYTHONPATH && export FLASK_APP=superset && export FLASK_ENV=development && export SUPERSET_SECRET_KEY=TEST && ./.venv/bin/superset run -p 8088 --with-threads --reload --debugger\""

# Frontend webpack dev server
osascript -e "tell application \"Terminal\" to do script \"cd '$SUPERSET_DIR/superset-frontend' && npm run dev-server\""


