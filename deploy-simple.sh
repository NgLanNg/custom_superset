#!/bin/bash
# Simple deployment script for Superset to VPS
set -euo pipefail

VPS_HOST="43.156.158.54"
VPS_USER="ubuntu"
PROJECT="superset-deploy"

echo "=== Superset Deployment ==="
echo "VPS: $VPS_HOST"
echo ""

# 1. Transfer image
echo "[1/6] Transferring Docker image..."
podman save localhost/superset-custom:latest | gzip > superset-custom.tar.gz
scp -o StrictHostKeyChecking=no superset-custom.tar.gz $VPS_USER@$VPS_HOST:~/$PROJECT/

# 2. Setup on VPS
echo "[2/6] Setting up VPS..."
ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST << 'REMOTE'
set -e
PROJECT="superset-deploy"
cd ~/$PROJECT

# Load image
podman load -i superset-custom.tar.gz || docker load -i superset-custom.tar.gz

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  superset:
    image: localhost/superset-custom:latest
    container_name: superset
    ports:
      - "8088:8088"
    environment:
      SUPERSET_DB_HOST: localhost
      SUPERSET_DB_PORT: 5432
      SUPERSET_DB_USER: superset
      SUPERSET_DB_PASS: superset
      SUPERSET_DB_NAME: superset
      SUPERSET_SECRET_KEY: supersetsupersecretkey123
      SUPERSET_GUEST_TOKEN_SECRET: guesttokensecret456
    command: superset run -p 8088 --host=0.0.0.0
    restart: unless-stopped
EOF

# Install Docker if needed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
fi

# Start Docker
sudo systemctl start docker || sudo service docker start

# Start Superset
docker-compose up -d

# Wait for startup
sleep 10

# Initialize database
docker exec superset superset db upgrade || true
docker exec superset superset init || true

echo ""
echo "=== Deployment Complete ==="
echo "Access: http://$(curl -s ifconfig.me):8088"
echo "Admin: admin / admin"
REMOTE

# Cleanup local files
rm -f superset-custom.tar.gz

echo ""
echo "=== Done! ==="
