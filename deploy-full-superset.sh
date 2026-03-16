#!/bin/bash
# Full Superset Deployment with Scenario Plugin
# This script deploys the complete Superset application including the custom scenario plugin

set -e

PROD_HOST="${1:-43.156.158.54}"
PROD_USER="${2:-ubuntu}"
SUPERSET_DIR="/Users/alan/dashboard/superset"
DEPLOY_DIR="/opt/superset"

echo "========================================"
echo "FULL SUPERSET DEPLOYMENT WITH PLUGIN"
echo "========================================"
echo "Target: ${PROD_USER}@${PROD_HOST}"
echo "Source: ${SUPERSET_DIR}"
echo "Deploy: ${DEPLOY_DIR}"
echo ""

# Check SSH
echo "Checking SSH connectivity..."
if ! ssh -o ConnectTimeout=5 "${PROD_USER}@${PROD_HOST}" "echo 'SSH OK'" 2>/dev/null; then
    echo "Error: Cannot connect"
    exit 1
fi

# Deploy commands
ssh "${PROD_USER}@${PROD_HOST}" << REMOTE_SCRIPT
set -e

echo "[Production] Stopping existing Superset..."
sudo systemctl stop superset 2>/dev/null || true

echo "[Production] Creating deployment directory..."
sudo mkdir -p "${DEPLOY_DIR}"
sudo chown \$(whoami):\$(whoami) "${DEPLOY_DIR}"

REMOTE_SCRIPT

echo ""
echo "[Local] Preparing deployment package..."

# Create a tarball of the superset directory (excluding node_modules and large files)
cd "$(dirname "$SUPERSET_DIR")"
tar czf /tmp/superset-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='*.tar.gz' \
  --exclude='.git' \
  --exclude='*.db' \
  --exclude='venv' \
  --exclude='.venv' \
  superset/

echo "[Local] Uploading to production..."
scp /tmp/superset-deploy.tar.gz "${PROD_USER}@${PROD_HOST}:/tmp/"

echo ""
echo "[Production] Extracting and setting up..."
ssh "${PROD_USER}@${PROD_HOST}" << REMOTE_SCRIPT2
set -e

cd "${DEPLOY_DIR}"

# Extract
echo "[Production] Extracting archive..."
tar xzf /tmp/superset-deploy.tar.gz

# Create virtual environment
echo "[Production] Setting up Python environment..."
cd "${DEPLOY_DIR}/superset"
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "[Production] Installing Python dependencies..."
pip install --upgrade pip
pip install -e ".[postgres]"
pip install psycopg2-binary

# Set up configuration
echo "[Production] Creating configuration..."
cat > superset_config.py << 'PYEOF'
import os

SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'change-me-in-production')

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{os.environ.get('SUPERSET_DB_USER', 'superset')}:{os.environ.get('SUPERSET_DB_PASS', 'superset')}@{os.environ.get('SUPERSET_DB_HOST', 'localhost')}:{os.environ.get('SUPERSET_DB_PORT', '5432')}/{os.environ.get('SUPERSET_DB_NAME', 'superset')}"

SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600,
}

ENABLE_CORS = True
CORS_OPTIONS = {
    "supports_credentials": True,
    "allow_headers": ["Content-Type", "Authorization", "X-CSRFToken"],
    "resources": {"*": {"origins": "*"}},
}

FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "EMBEDDABLE_CHARTS": True,
}

SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False
PYEOF

echo "[Production] Initializing database..."
export FLASK_APP=superset
export SUPERSET_SECRET_KEY=\$(openssl rand -base64 42)
export SUPERSET_DB_HOST=localhost
export SUPERSET_DB_PORT=5432
export SUPERSET_DB_USER=superset
export SUPERSET_DB_PASS=superset
export SUPERSET_DB_NAME=superset

superset db upgrade
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin || true
superset init || true

echo "[Production] Building frontend..."
cd superset-frontend
npm ci --legacy-peer-deps
npm run build

echo "[Production] Creating systemd service..."
sudo tee /etc/systemd/system/superset.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Apache Superset
After=network.target postgresql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/superset/superset
Environment="PATH=/opt/superset/superset/venv/bin"
Environment="PYTHONPATH=/opt/superset/superset"
Environment="FLASK_APP=superset"
ExecStart=/opt/superset/superset/venv/bin/superset run -h 0.0.0.0 -p 8088
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEEOF

sudo systemctl daemon-reload
sudo systemctl enable superset
sudo systemctl start superset

echo ""
echo "[Production] Deployment complete!"
echo "[Production] URL: http://${PROD_HOST}:8088"
echo "[Production] Login: admin / admin"

REMOTE_SCRIPT2

echo ""
echo "========================================"
echo "DEPLOYMENT COMPLETE"
echo "========================================"
