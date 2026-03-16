import os
from typing import Any

# Base configuration values
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "A_VERY_SECURE_RANDOM_KEY")
SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.expanduser('~/.superset')}/superset.db?check_same_thread=false"

# Allow framing embedding for all domains during local development
SESSION_COOKIE_SAMESITE = None
ENABLE_CORS = True
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources': ['*'],
    'origins': ['*']
}

# Feature Flags
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "EMBEDDABLE_CHARTS": True,
    "AG_GRID_TABLE_ENABLED": True,
    "DASHBOARD_RBAC": True
}

# Use standalone views without the nav bar for embedding
PUBLIC_ROLE_LIKE = "Gamma"  # Allow public viewing if desired

# Guest token JWT — required by @superset-ui/embedded-sdk
GUEST_TOKEN_JWT_SECRET = os.environ.get(
    "SUPERSET_GUEST_TOKEN_SECRET", "scenario-guest-token-secret-changeme"
)
GUEST_TOKEN_JWT_AUDIENCE = "superset"
GUEST_ROLE_NAME = "Public"

# Register custom scenario write-back blueprint
# Deferred to avoid importing superset.views before the Flask app is initialized
# (which causes "App not initialized yet / call init_app first" in encrypt.py)
def FLASK_APP_MUTATOR(app):  # noqa: N802
    try:
        from superset.views.scenario_writeback import scenario_bp  # noqa: E402
        app.register_blueprint(scenario_bp, url_prefix='/api/v1/scenario')
    except ImportError:
        pass  # Blueprint not yet created
