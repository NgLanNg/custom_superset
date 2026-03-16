#!/bin/bash
# SSH Deployment Script for Superset Production
# Usage: ./deploy-via-ssh.sh [production-host] [user]
# Example: ./deploy-via-ssh.sh 43.156.158.54 ubuntu

set -e

# Configuration
PROD_HOST="${1:-43.156.158.54}"
PROD_USER="${2:-ubuntu}"
REPO_URL="https://github.com/NgLanNg/custom_superset.git"
DEPLOY_DIR="/opt/custom_superset"
VENV_DIR="/opt/custom_superset/venv"

echo "========================================"
echo "SSH DEPLOYMENT TO PRODUCTION"
echo "========================================"
echo ""
echo "Target: ${PROD_USER}@${PROD_HOST}"
echo "Repository: ${REPO_URL}"
echo "Deploy Directory: ${DEPLOY_DIR}"
echo ""

# Check SSH connectivity
echo "Step 1: Checking SSH connectivity..."
if ! ssh -o ConnectTimeout=5 "${PROD_USER}@${PROD_HOST}" "echo 'SSH OK'" 2>/dev/null; then
    echo "Error: Cannot connect to ${PROD_HOST} via SSH"
    exit 1
fi
echo "SSH connection: OK"
echo ""

# Deploy commands via SSH
echo "Step 2: Deploying to production..."
ssh "${PROD_USER}@${PROD_HOST}" << REMOTE_SCRIPT

set -e

DEPLOY_DIR="/opt/custom_superset"
REPO_URL="https://github.com/NgLanNg/custom_superset.git"
VENV_DIR="/opt/custom_superset/venv"

echo "[Production] Starting deployment..."

# Install system dependencies
echo "[Production] Installing system dependencies..."
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-pip python3-venv python3-dev build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev postgresql-client postgresql-server-dev-all libpq-dev git

# Create directory if doesn't exist
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "[Production] Creating deployment directory..."
    sudo mkdir -p "$DEPLOY_DIR"
    sudo chown \$(whoami):\$(whoami) "$DEPLOY_DIR"
fi

cd "$DEPLOY_DIR"

# Clone or pull
if [ -d ".git" ]; then
    echo "[Production] Pulling latest code..."
    git fetch origin
    git reset --hard origin/main
else
    echo "[Production] Cloning repository..."
    git clone "$REPO_URL" .
fi

echo "[Production] Code updated successfully"

# Create virtual environment
echo "[Production] Setting up Python virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

# Install Superset
echo "[Production] Installing Apache Superset..."
pip install --upgrade pip --quiet
pip install apache-superset[postgres] --quiet

# Install additional dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "[Production] Installing project dependencies..."
    pip install -r requirements.txt --quiet
fi

# Set environment variables
echo "[Production] Configuring environment..."
export SUPERSET_SECRET_KEY="\${SUPERSET_SECRET_KEY:-\$(openssl rand -base64 42)}"
export SUPERSET_DB_HOST="\${SUPERSET_DB_HOST:-localhost}"
export SUPERSET_DB_PORT="\${SUPERSET_DB_PORT:-5432}"
export SUPERSET_DB_USER="\${SUPERSET_DB_USER:-superset}"
export SUPERSET_DB_PASS="\${SUPERSET_DB_PASS:-superset}"
export SUPERSET_DB_NAME="\${SUPERSET_DB_NAME:-superset}"
export FLASK_APP=superset

# Create superset config
echo "[Production] Creating Superset configuration..."
cat > superset_config.py << 'CONFIG'
import os

SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'change-me-in-production')

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{os.environ.get('SUPERSET_DB_USER', 'superset')}:{os.environ.get('SUPERSET_DB_PASS', 'superset')}@{os.environ.get('SUPERSET_DB_HOST', 'localhost')}:{os.environ.get('SUPERSET_DB_PORT', '5432')}/{os.environ.get('SUPERSET_DB_NAME', 'superset')}"

SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
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
    "AG_GRID_TABLE_ENABLED": True,
}

SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False
CONFIG

# Initialize Superset
echo "[Production] Initializing Superset..."
superset db upgrade
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin || true
superset init || true

# Create systemd service
echo "[Production] Creating systemd service..."
sudo tee /etc/systemd/system/superset.service > /dev/null << 'SERVICE'
[Unit]
Description=Apache Superset
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/custom_superset
Environment="PATH=/opt/custom_superset/venv/bin"
Environment="SUPERSET_SECRET_KEY=change-me-in-production"
Environment="SUPERSET_DB_HOST=localhost"
Environment="SUPERSET_DB_PORT=5432"
Environment="SUPERSET_DB_USER=superset"
Environment="SUPERSET_DB_PASS=superset"
Environment="SUPERSET_DB_NAME=superset"
Environment="FLASK_APP=superset"
ExecStart=/opt/custom_superset/venv/bin/superset run -h 0.0.0.0 -p 8088
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable superset

# Start service
echo "[Production] Starting Superset service..."
sudo systemctl restart superset || sudo systemctl start superset

sleep 5

echo "[Production] Deployment complete!"
echo "[Production] Service status:"
sudo systemctl status superset --no-pager || echo "Service status check failed"

echo ""
echo "[Production] Superset URL: http://43.156.158.54:8088"
echo "[Production] Login: admin / admin"

REMOTE_SCRIPT

echo ""
echo "========================================"
echo "DEPLOYMENT COMPLETE"
echo "========================================"
echo ""
echo "Access Superset at:"
echo "  http://43.156.158.54:8088"
echo ""
echo "Default login:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "To check status:"
echo "  ssh ubuntu@43.156.158.54 'sudo systemctl status superset'"
echo ""
