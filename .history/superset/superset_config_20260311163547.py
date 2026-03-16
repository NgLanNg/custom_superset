import os
import sys

# Base configuration values
# Critical C3: Removed hardcoded fallback secret to prevent forgeable sessions.
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")
if not SECRET_KEY and "superset" in sys.argv[0]:
    # Only crash if we are actually running the superset server/cli
    print("FATAL: SUPERSET_SECRET_KEY environment variable is required.")
    sys.exit(1)

_PG_URI = "postgresql+psycopg2://superset:superset@localhost:5432/superset"

# Support for RDS SSL
db_uri_env = os.environ.get("SUPERSET_DATABASE_URI")
if not db_uri_env:
    # Build from components if provided
    db_host = os.environ.get("SUPERSET_DB_HOST")
    if db_host:
        db_port = os.environ.get("SUPERSET_DB_PORT", "5432")
        db_user = os.environ.get("SUPERSET_DB_USER", "postgres")
        db_pass = os.environ.get("SUPERSET_DB_PASS", "")
        db_name = os.environ.get("SUPERSET_DB_NAME", "superset")
        db_uri_env = f"postgresql+psycopg2://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"
        
        # Add SSL if configured
        if os.environ.get("SUPERSET_DB_SSL", "").lower() in ("true", "1", "yes"):
            ssl_cert_path = os.environ.get("SUPERSET_DB_SSL_CERT_PATH", "")
            if ssl_cert_path:
                db_uri_env += f"?sslmode=verify-full&sslrootcert={ssl_cert_path}"
            else:
                db_uri_env += "?sslmode=require"

SQLALCHEMY_DATABASE_URI = db_uri_env or _PG_URI
SQLALCHEMY_EXAMPLES_URI = SQLALCHEMY_DATABASE_URI

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
# Use FLASK_APP_MUTATOR to avoid "App not initialized" errors by deferring imports until view registration.
def FLASK_APP_MUTATOR(app):  # noqa: N802
    pass  # Views registered in superset/initialization/__init__.py
