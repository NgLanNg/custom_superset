import os
import sys

# Base configuration values
# Critical C3: Removed hardcoded fallback secret to prevent forgeable sessions.
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")
if not SECRET_KEY and "superset" in sys.argv[0]:
    # Only crash if we are actually running the superset server/cli
    print("FATAL: SUPERSET_SECRET_KEY environment variable is required.")
    sys.exit(1)

SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.expanduser('~/.superset')}/superset.db?check_same_thread=false"

# Allow framing embedding for all domains during local development
SESSION_COOKIE_SAMESITE = None
ENABLE_CORS = True
# Critical C4: CORS 'origins: *' with 'supports_credentials: True' is a security vector.
# For local development we can be more specific or disable credentials if * is needed.
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources': ['*'],
    'origins': [
        'http://localhost:8088',
        'http://localhost:9000',
        'http://127.0.0.1:8088',
        'http://127.0.0.1:9000'
    ]
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
GUEST_TOKEN_JWT_SECRET = os.environ.get("SUPERSET_GUEST_TOKEN_SECRET")
# Critical C3: Removed hardcoded fallback secret to avoid session forging.
GUEST_TOKEN_JWT_AUDIENCE = "superset"
GUEST_ROLE_NAME = "Public"

# Register custom scenario write-back view
# Deferred to avoid importing superset.views before the Flask app is initialized
def FLASK_APP_MUTATOR(app):  # noqa: N802
    from superset.extensions import appbuilder
    try:
        from superset.views.scenario_writeback import ScenarioWritebackView  # noqa: E402
        appbuilder.add_view_no_menu(ScenarioWritebackView)
    except ImportError:
        pass  # View not yet created
