import os
import sys

# =============================================================================
# Production-Ready Superset Configuration for Alibaba Cloud
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Secret Key Configuration
# -----------------------------------------------------------------------------
# Critical C3: In production, use a strong random secret stored in Alibaba
# Cloud Secrets Manager or environment variables.
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")
if not SECRET_KEY:
    if "superset" in sys.argv[0] and "db upgrade" not in " ".join(sys.argv):
        print("FATAL: SUPERSET_SECRET_KEY environment variable is required.")
        print("Generate a secure key: openssl rand -base64 42")
        sys.exit(1)

# -----------------------------------------------------------------------------
# 2. Database Configuration
# -----------------------------------------------------------------------------
# Alibaba Cloud RDS (PostgreSQL) connection string
# Format: postgresql+psycopg2://user:password@host:port/database
_DATABASE_HOST = os.environ.get("SUPERSET_DB_HOST", "localhost")
_DATABASE_PORT = os.environ.get("SUPERSET_DB_PORT", "5432")
_DATABASE_USER = os.environ.get("SUPERSET_DB_USER", "superset")
_DATABASE_PASS = os.environ.get("SUPERSET_DB_PASS", "superset")
_DATABASE_NAME = os.environ.get("SUPERSET_DB_NAME", "superset")

# Build the database URI from components
SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{_DATABASE_USER}:{_DATABASE_PASS}@{_DATABASE_HOST}:{_DATABASE_PORT}/{_DATABASE_NAME}"
SQLALCHEMY_EXAMPLES_URI = SQLALCHEMY_DATABASE_URI

# Connection pool settings for production
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
}

# -----------------------------------------------------------------------------
# 3. CORS Configuration
# -----------------------------------------------------------------------------
# For Alibaba Cloud deployment, configure CORS with your domain/IP
ENABLE_CORS = True
CORS_OPTIONS = {
    "supports_credentials": True,
    "allow_headers": ["Content-Type", "Authorization", "X-CSRFToken"],
    "resources": {"*": {"origins": "*"}},  # In production, restrict to your domain
}

# -----------------------------------------------------------------------------
# 4. Feature Flags
# -----------------------------------------------------------------------------
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "EMBEDDABLE_CHARTS": True,
    "AG_GRID_TABLE_ENABLED": True,
    "DASHBOARD_RBAC": True,
    "GLOBAL_ASYNC_QUERIES": False,
    "SHARED_QUERIES": True,
}

# -----------------------------------------------------------------------------
# 5. Security Settings
# -----------------------------------------------------------------------------
SESSION_COOKIE_SAMESITE = "Lax"  # Changed from None for better security
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False  # Set True if using HTTPS with valid cert

# Guest Token JWT - Required for embedded dashboards
GUEST_TOKEN_JWT_SECRET = os.environ.get("SUPERSET_GUEST_TOKEN_SECRET")
if not GUEST_TOKEN_JWT_SECRET:
    print("WARNING: SUPERSET_GUEST_TOKEN_SECRET not set. Embedding may not work.")

GUEST_TOKEN_JWT_AUDIENCE = "superset"
GUEST_ROLE_NAME = "Public"

# -----------------------------------------------------------------------------
# 6. Server Configuration
# -----------------------------------------------------------------------------
SUPERSET_HOME = "/app/superset_home"
DATA_DIR = "/app/superset_home/data"
UPLOAD_FOLDER = "/app/superset_home/uploads"
REPORTS_FOLDER = "/app/superset_home/reports"
EXPORT_FOLDER = "/app/superset_home/export"

os.makedirs(SUPERSET_HOME, exist_ok=True)
os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(REPORTS_FOLDER, exist_ok=True)
os.makedirs(EXPORT_FOLDER, exist_ok=True)

# -----------------------------------------------------------------------------
# 7. Cache Configuration
# -----------------------------------------------------------------------------
# Use filesystem-based cache for production (or Redis for better scalability)
CACHE_CONFIG = {
    "CACHE_TYPE": "FileSystemCache",
    "CACHE_DIR": "/app/superset_home/cache",
    "CACHE_DEFAULT_TIMEOUT": 300,
}

# -----------------------------------------------------------------------------
# 8. Logging
# -----------------------------------------------------------------------------
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
LOG_LEVEL = "INFO"

# -----------------------------------------------------------------------------
# 9. Plugin Registration
# -----------------------------------------------------------------------------
# Custom views are registered in superset/initialization/__init__.py
# The ScenarioWritebackView is already registered there


# -----------------------------------------------------------------------------
# 10. Flask App Mutator
# -----------------------------------------------------------------------------
def FLASK_APP_MUTATOR(app):
    """
    Hook to modify the Flask app after initialization.
    Use this to register additional blueprints or modify configuration.
    """
    pass
