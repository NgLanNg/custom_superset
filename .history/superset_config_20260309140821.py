import os

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
