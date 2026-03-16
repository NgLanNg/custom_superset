---
type: documentation
date: 2026-03-15
author: Deployment Guide
category: deployment
title: Alibaba Cloud Deployment Guide for Custom Superset
version: 1.0
---

# Alibaba Cloud Deployment Guide for Custom Superset

This guide covers deploying the Custom Superset dashboard with the Scenario Planning plugin (`plugin-chart-scenario`) to Alibaba Cloud LightHouse.

## Overview

The deployment consists of:

- **PostgreSQL 16** - Database container for metadata and scenario data
- **Superset Base** - Custom Superset image with scenario plugin pre-built
- **Scenario API** - Write-back endpoints for cell edits

```
+------------------------+
| Alibaba Cloud ECS      |
| (Ubuntu 22.04 LTS)     |
|                        |
| +--------------------+ |
| | Docker Compose     | |
| |                    | |
| | +--------------+   | |
| | | PostgreSQL   |   | |
| | | :5432        |   | |
| | +--------------+   | |
| |                    | |
| | +--------------+   | |
| | | Superset     |   | |
| | | :8088        |   | |
| | +--------------+   | |
| +--------------------+ |
+------------------------+
```

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Alibaba Cloud LightHouse | Ubuntu 22.04 LTS |
| CPU/RAM | 4+ CPU, 8+ GB RAM |
| Docker | 24+ |
| Docker Compose | 2.20+ |
| Network | Port 8088 open in security group |

---

## Quick Start

### Step 1: Prepare Your Server

```bash
# SSH to your Alibaba Cloud instance
ssh root@YOUR_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add your user to docker group
usermod -aG docker $USER
```

### Step 2: Prepare Project Files

```bash
# Create working directory
mkdir -p ~/superset-deploy
cd ~/superset-deploy

# Copy project files (via git or SCP)
git clone https://github.com/your/repo.git .
# or
scp -r user@your-local:/path/to/project/* .
```

### Step 3: Create Environment Configuration

```bash
# Create .env file
cat > .env << 'EOF'
# PostgreSQL Configuration
SUPERSET_POSTGRES_PASSWORD=your_secure_password_here

# Secret Keys (generate with: openssl rand -base64 42)
SUPERSET_SECRET_KEY=your_secret_key_here
SUPERSET_GUEST_TOKEN_SECRET=your_guest_token_secret_here

# Database Configuration (no quotes in values)
SUPERSET_DB_HOST=postgres
SUPERSET_DB_PORT=5432
SUPERSET_DB_USER=superset
SUPERSET_DB_NAME=superset
SUPERSET_DB_SSL=false
EOF

# Generate secure secrets if not set
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
export SUPERSET_GUEST_TOKEN_SECRET=$(openssl rand -base64 42)
```

### Step 4: Build and Start Services

```bash
# Build the Docker images
docker-compose build superset

# Start all services
docker-compose up -d

# Monitor startup logs
docker-compose logs -f superset
```

### Step 5: Initialize Database Schema

```bash
# Wait for PostgreSQL to be healthy (check logs first)
docker-compose ps

# Run Superset migrations
docker exec -it superset-base superset db upgrade

# Initialize roles and permissions
docker exec -it superset-base superset init

# Create scenario table
docker exec -i superset-postgres psql -U superset -d superset \
    -f /app/scripts/init_db_script/create_scenario_table.sql

# Load seed data
docker exec -i superset-postgres psql -U superset -d superset \
    -f /app/scripts/init_db_script/populate_scenario_data.sql
```

### Step 6: Create Admin User

```bash
# Create admin user (only if needed)
docker exec -it superset-base superset fab create-admin \
    --username admin \
    --email admin@example.com \
    --firstname Admin \
    --lastname User \
    --password admin
```

### Step 7: Register Database in Superset

```bash
# Use the init script to register the database connection
cd ~/superset-deploy/superset
docker exec -it superset-base bash -c "
    export FLASK_APP=superset
    export SUPERSET_SECRET_KEY=\${SUPERSET_SECRET_KEY:-TEST}
    export SUPERSET_DB_HOST=postgres
    export SUPERSET_DB_PORT=5432
    export SUPERSET_DB_USER=superset
    export SUPERSET_DB_PASS=\${SUPERSET_POSTGRES_PASSWORD:-superset}
    export SUPERSET_DB_NAME=superset
    .venv/bin/python scripts/register_db.py
"
```

---

## Accessing Superset

### Basic Access

Open your browser and navigate to:

```
http://YOUR_SERVER_IP:8088
```

### Login

- **Username:** `admin`
- **Password:** `admin` (or your custom password)

---

## Verifying the Custom Plugin

1. Go to **Dashboards** > **+ New Dashboard**
2. Click **+ Add Chart**
3. Look for **Scenario Creator** in the chart list
4. The chart should show 4 OPUs with equity share percentages

---

## Project Structure

| Path | Purpose |
|------|---------|
| `docker-compose.yml` | Service definitions (PostgreSQL + Superset) |
| `Dockerfile.superset` | Custom Superset image build |
| `docker-entrypoint.sh` | Container initialization script |
| `superset_config.py` | Production configuration |
| `scripts/init_db_script/` | Database schema and seed data |
| `superset-frontend/plugins/plugin-chart-scenario/` | Custom chart plugin |

---

## Production Hardening

### 1. HTTPS with Nginx Reverse Proxy

```bash
# Install Nginx
apt install -y nginx

# Configure for Superset
cat > /etc/nginx/sites-available/superset << 'NGINX'
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX

ln -s /etc/nginx/sites-available/superset /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
```

### 2. Firewall Configuration

```bash
# Allow only necessary ports
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 3. Docker Security

```bash
# Use non-root user in Docker
# Configure Docker Content Trust
export DOCKER_CONTENT_TRUST=1
```

---

## Database Operations

### Backup

```bash
# Backup all databases
docker exec superset-postgres pg_dump -U superset superset \
    > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup specific schema
docker exec superset-postgres pg_dump -U superset superset -n public \
    > backup_public_$(date +%Y%m%d).sql
```

### Restore

```bash
# Restore from backup
docker exec -i superset-postgres psql -U superset -d superset \
    < backup.sql
```

### View Data

```bash
# Query the scenario table
docker exec -it superset-postgres psql -U superset -d superset \
    -c "SELECT * FROM silver_scenario_equity_share LIMIT 10;"
```

---

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs superset
docker-compose logs postgres

# Check if ports are in use
docker-compose ps
ss -tlnp | grep :8088
```

### Database connection failed

```bash
# Verify PostgreSQL is running
docker-compose ps

# Check PostgreSQL logs
docker-compose logs postgres

# Test connection manually
docker exec -it superset-postgres psql -U superset -d superset -c "SELECT 1;"
```

### Superset.init() fails

```bash
# Run migrations individually
docker exec -it superset-base superset db upgrade
docker exec -it superset-base superset init

# Check database schema
docker exec -it superset-postgres psql -U superset -d superset \
    -c "\dt"
```

### Plugin not showing in chart list

```bash
# Rebuild the frontend with the plugin
docker-compose down
docker-compose build superset
docker-compose up -d

# Check logs for build errors
docker-compose logs superset
```

### Permission denied errors

```bash
# Fix file permissions
chown -R $USER:$USER ~/superset-deploy

# Or in container
docker exec -it superset-base chown -R superset:superset /app
```

---

## Maintenance

### Update Application

```bash
# Pull latest changes
cd ~/superset-deploy
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build superset
docker-compose up -d

# Run migrations if needed
docker exec -it superset-base superset db upgrade
```

### View Container Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f superset
docker-compose logs -f postgres
```

### Restart Service

```bash
docker-compose restart superset
# or
docker-compose stop superset && docker-compose start superset
```

---

## Configuration Reference

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPERSET_POSTGRES_PASSWORD` | Yes | superset | PostgreSQL password |
| `SUPERSET_SECRET_KEY` | Yes | change-me | Session signing key |
| `SUPERSET_GUEST_TOKEN_SECRET` | Yes | change-me | Embedded SDK auth |
| `SUPERSET_DB_HOST` | No | postgres | Database hostname |
| `SUPERSET_DB_PORT` | No | 5432 | Database port |
| `SUPERSET_DB_USER` | No | superset | Database user |
| `SUPERSET_DB_NAME` | No | superset | Database name |

### Network Ports

| Port | Service | Purpose |
|------|---------|---------|
| 5432 | PostgreSQL | Database (internal) |
| 8088 | Superset | Web interface |
| 80 | Nginx | Reverse proxy (optional) |

---

## API Endpoints

### Health Check

```bash
curl http://localhost:8088/health
curl http://localhost:8088/api/v1/scenario/health
```

### Write-back API

```bash
curl -X POST http://localhost:8088/api/v1/scenario/writeback \
    -H "Content-Type: application/json" \
    -d '{
        "scenario_name": "existing_assets",
        "bu": "LNGA",
        "opu": "MLNG",
        "year": 2025,
        "value": 75
    }'
```

### Emission Sources

```bash
curl http://localhost:8088/api/v1/scenario/emission-sources?bu=LNGA&opu=MLNG
```

---

##+ Test

```bash
# Verify PostgreSQL is running
docker-compose ps

# Test database connectivity
docker exec superset-postgres pg_isready -U superset

# Test Superset is responding
curl -s http://localhost:8088/health | jq

# Check container logs
docker-compose logs --tail=50 superset
```

---

## Support

For issues:

1. Check logs: `docker-compose logs -f superset`
2. Verify ports: `ss -tlnp | grep :8088`
3. Test database: `docker exec -it superset-postgres psql -U superset -d superset`

---

**Version:** 1.0
**Last Updated:** 2026-03-15
**Maintainer:** Platform Team
