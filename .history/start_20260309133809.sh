#!/bin/bash
export FLASK_APP="superset"
export SUPERSET_SECRET_KEY="A_VERY_SECURE_RANDOM_KEY"

# Open a new terminal tab to run the backend
osascript -e 'tell application "Terminal" to do script "cd '$PWD'/superset && export FLASK_ENV=development && export FLASK_APP=superset && export SUPERSET_SECRET_KEY=TEST && ./.venv/bin/superset run -p 8088 --with-threads --reload --debugger"'
# Open a new terminal tab to run the frontend webpack-dev-server
osascript -e 'tell application "Terminal" to do script "cd '$PWD'/superset/superset-frontend && npm run dev-server"'
