#!/bin/bash
# Deploy Superset to VPS
# Uses podman for local container ops
# Uses SSH/Fish to connect to VPS
# Installs Docker on VPS and runs Superset

set -euo pipefail

VPS_HOST="43.156.158.54"
VPS_USER="ubuntu"
IMAGE_NAME="superset-custom"
IMAGE_TAG="latest"
PROJECT_DIR="superset-deploy"
SSH_IDENTITY="${SSH_IDENTITY:-$HOME/.ssh/id_rsa}"

echo "========================================"
echo "Superset Deployment to VPS"
echo "========================================"
echo ""
echo "VPS: $VPS_USER@$VPS_HOST"
echo "Project: ~/$PROJECT_DIR"
echo ""

# Step 1: Save and transfer Docker image
echo "Step 1: Saving and transferring Docker image to VPS..."
podman save localhost/$IMAGE_NAME:$IMAGE_TAG | gzip > /Users/alan/dashboard/$IMAGE_NAME.tar.gz

echo "  Image saved: $IMAGE_NAME.tar.gz ($(du -h /Users/alan/dashboard/$IMAGE_NAME.tar.gz | cut -f1))"

ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "mkdir -p ~/$PROJECT_DIR"
scp -i $SSH_IDENTITY $IMAGE_NAME.tar.gz $VPS_USER@$VPS_HOST:~/$PROJECT_DIR/

# Step 2: Load image on VPS
echo ""
echo "Step 2: Loading image on VPS..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cd ~/$PROJECT_DIR && gunzip -c $IMAGE_NAME.tar.gz | podman load"

# Step 3: Install Docker on VPS
echo ""
echo "Step 3: Installing Docker on VPS..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST << 'EOF'
# Install Docker
curl -fsSL https://get.docker.com -o /tmp/install-docker.sh
sudo sh /tmp/install-docker.sh
sudo usermod -aG docker $USER
# Clean up
rm -f /tmp/install-docker.sh
echo "Docker installed successfully"
EOF

echo "  Waiting for Docker to be ready..."
sleep 5

# Step 4: Create docker-compose.yml on VPS
echo ""
echo "Step 4: Setting up project on VPS..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "mkdir -p ~/$PROJECT_DIR/project"

# Create docker-compose.yml
echo "  Creating docker-compose.yml..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cat > ~/$PROJECT_DIR/project/docker-compose.yml" << 'EOF'
services:
  superset:
    image: superset-custom
    container_name: superset-base
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

# Transfer superset_config.py
echo "  Transferring superset_config.py..."
scp -i $SSH_IDENTITY /Users/alan/dashboard/superset/superset_config_local.py $VPS_USER@$VPS_HOST:~/$PROJECT_DIR/project/superset_config.py

# Transfer entrypoint script
echo "  Transferring entrypoint script..."
scp -i $SSH_IDENTITY /Users/alan/dashboard/superset-entrypoint.sh $VPS_USER@$VPS_HOST:~/$PROJECT_DIR/project/docker-entrypoint.sh
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "chmod +x ~/$PROJECT_DIR/project/docker-entrypoint.sh"

# Transfer init scripts
echo "  Transferring init scripts..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "mkdir -p ~/$PROJECT_DIR/project/scripts/init_db_script"
for file in /Users/alan/dashboard/scripts/init_db_script/*; do
    scp -i $SSH_IDENTITY "$file" $VPS_USER@$VPS_HOST:~/$PROJECT_DIR/project/scripts/init_db_script/
done

# Transfer plugin
echo "  Transferring plugin-chart-scenario..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "mkdir -p ~/$PROJECT_DIR/project/plugins"
scp -r -i $SSH_IDENTITY /Users/alan/dashboard/superset/superset-frontend/plugins/plugin-chart-scenario $VPS_USER@$VPS_HOST:~/$PROJECT_DIR/project/plugins/

# Step 5: Start Docker and run Superset
echo ""
echo "Step 5: Starting Docker service..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "sudo systemctl start docker || sudo service docker start"

echo ""
echo "Step 6: Starting Superset..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cd ~/$PROJECT_DIR/project && docker-compose up -d superset"

# Wait for container to start
sleep 5

# Step 7: Check status
echo ""
echo "Step 7: Checking container status..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cd ~/$PROJECT_DIR/project && docker-compose ps"

# Step 8: Initialize database
echo ""
echo "Step 8: Running database migrations..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cd ~/$PROJECT_DIR/project && docker exec superset-base superset db upgrade"

echo ""
echo "Step 9: Initializing Superset..."
ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST "cd ~/$PROJECT_DIR/project && docker exec superset-base superset init"

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Access: http://$VPS_HOST:8088"
echo ""
echo "Admin credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "SSH to VPS:"
echo "  ssh -i $SSH_IDENTITY $VPS_USER@$VPS_HOST"
echo "  cd ~/$PROJECT_DIR/project"
echo "  docker-compose logs -f superset"
echo ""
echo "To stop Superset:"
echo "  docker-compose down"
echo ""
