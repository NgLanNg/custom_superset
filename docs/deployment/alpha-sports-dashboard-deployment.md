---
type: documentation
date: 2026-03-15
author: Deployment Guide
category: deployment
title: Alpha Sports Dashboard Deployment
version: 1.0
---

# Alpha Sports Dashboard Deployment - Complete Guide

This guide covers deploying the Alpha Sports Dashboard (Scenario Planning) to Alibaba Cloud.

---

## Architecture Overview

```
+------------------------+
| Alibaba Cloud ECS      |
| Ubuntu 22.04 LTS       |
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
         |
    External Access
         |
    +--------+
    | User |
    +--------+
```

---

## Prerequisites

| Component | Version/Requirement |
|-----------|---------------------|
| Alibaba Cloud | LightHouse or ECS |
| OS | Ubuntu 22.04 LTS |
| CPU | 4+ cores |
| RAM | 8+ GB |
| Docker | 24+ |
| Docker Compose | 2.20+ |
|开放端口 | 8088 (Superset), 5432 (PostgreSQL - internal) |

---

## Installation Steps

### Step 1: Server Preparation

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

# Add user to docker group
usermod -aG docker $USER
reboot
```

### Step 2: Project Setup

```bash
# Create working directory
mkdir -p ~/alpha-sports-dashboard
cd ~/alpha-sports-dashboard

# Clone project
git clone https://github.com/your/alpha-sports-dashboard.git .
# or copy via SCP/rsync
```

### Step 3: Environment Configuration

```bash
# Create .env file
cat > .env << 'EOF'
# PostgreSQL Configuration
SUPERSET_POSTGRES_PASSWORD=YourSecurePassword123!

# Secret Keys (generate: openssl rand -base64 42)
SUPERSET_SECRET_KEY=YourSecretKeyHere
SUPERSET_GUEST_TOKEN_SECRET=YourGuestTokenSecret

# Database Configuration
SUPERSET_DB_HOST=postgres
SUPERSET_DB_PORT=5432
SUPERSET_DB_USER=superset
SUPERSET_DB_NAME=superset
EOF

# Generate secrets
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
export SUPERSET_GUEST_TOKEN_SECRET=$(openssl rand -base64 42)

# Verify .env exists
ls -la .env
```

### Step 4: Build Docker Images

```bash
# Build Superset with custom plugin
docker-compose build superset

# Monitor build progress
docker-compose build superset --progress=plain
```

### Step 5: Start Services

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# Monitor startup logs
docker-compose logs -f superset
```

### Step 6: Database Initialization

```bash
# Wait for PostgreSQL to be healthy
docker exec superset-postgres pg_isready -U superset

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

### Step 7: Create Admin User

```bash
# Create admin user (if not auto-created)
docker exec -it superset-base superset fab create-admin \
    --username admin \
    --email admin@alphasports.com \
    --firstname Alpha \
    --lastname Sports \
    --password admin
```

---

## Accessing the Dashboard

### Basic Access

Open your browser to:

```
http://YOUR_SERVER_IP:8088
```

### Login Credentials

- **Username:** `admin`
- **Password:** `admin` (or your custom password)

---

## Verification Checklist

- [ ] Superset web UI loads at `http://IP:8088`
- [ ] PostgreSQL is accessible on port 5432
- [ ] Scenario Creator chart appears in chart list
- [ ] Can create a dashboard with Scenario chart
- [ ] Can see 4 OPUs (MLNG, LNGC2, LNGC3, ALNG)
- [ ] Can edit equity share values
- [ ] Write-back API works (`/api/v1/scenario/writeback`)

---

## Project File Structure

```
~/alpha-sports-dashboard/
├── docker-compose.yml                    # Service definitions
├── Dockerfile.superset                   # Superset image build
├── docker-entrypoint.sh                  # Initialization script
├── .env                                  # Environment variables
├── superset/
│   ├── superset_config.py               # Config override
│   └── superset/
│       ├── views/
│       │   ├── scenario_writeback.py    # Write-back API
│       │   ├── scenario_metadata.py     # Metadata API
│       │   └── scenario.py              # Scenario view
│       └── superset-frontend/
│           └── plugins/
│               └── plugin-chart-scenario/
├── scripts/
│   └── init_db_script/
│       ├── create_scenario_table.sql
│       ├── populate_scenario_data.sql
│       ├── create_emission_sources_table.sql
│       └── populate_emission_sources.sql
├── docs/
│   └── deployment/
│       ├── alibaba-cloud-deployment-guide.md
│       ├── docker-reference.md
│       └── troubleshooting-guide.md
└── _archive/                             # Archived files
```

---

## Common Operations

### View Service Status

```bash
# All services
docker-compose ps

# Specific service
docker-compose ps superset
docker-compose ps postgres
```

### View Logs

```bash
# All logs
docker-compose logs -f

# Specific service
docker-compose logs -f superset
docker-compose logs -f postgres

# Filter logs
docker-compose logs | grep -i "error"
```

### Restart Service

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart superset
docker-compose restart postgres
```

### Stop Services

```bash
# Stop only
docker-compose stop

# Stop and remove
docker-compose down

# Stop, remove, and delete volumes
docker-compose down -v
```

### Update Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build superset
docker-compose up -d

# Run migrations if needed
docker exec -it superset-base superset db upgrade
```

---

## API Documentation

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

### Emission Sources API

```bash
# Get all emission sources
curl http://localhost:8088/api/v1/scenario/emission-sources

# Filter by BU and OPU
curl "http://localhost:8088/api/v1/scenario/emission-sources?bu=LNGA&opu=MLNG"

# Get by scenario
curl "http://localhost:8088/api/v1/scenario/emission-sources?scenario_id=base"
```

---

## Database Operations

### Backup Database

```bash
# Full backup
docker exec superset-postgres pg_dump -U superset superset \
    > backup_$(date +%Y%m%d_%H%M%S).sql

# Specific schema
docker exec superset-postgres pg_dump -U superset superset -n public \
    > backup_public_$(date +%Y%m%d).sql
```

### Restore Database

```bash
# Restore from backup
docker exec -i superset-postgres psql -U superset -d superset \
    < backup.sql
```

### Query Data

```bash
# Query scenario equity share
docker exec -it superset-postgres psql -U superset -d superset \
    -c "SELECT * FROM silver_scenario_equity_share LIMIT 10;"

# Query emission sources
docker exec -it superset-postgres psql -U superset -d superset \
    -c "SELECT * FROM silver_emission_by_sources LIMIT 10;"
```

---

## Performance Optimizations

### Database Indexes

```sql
-- Existing indexes
CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
ON silver_scenario_equity_share(scenario_name, bu, opu);

-- Additional indexes for better performance
CREATE INDEX IF NOT EXISTS idx_emission_by_bu_opu
ON silver_emission_by_sources(bu, opu);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_year
ON silver_scenario_equity_share(year);
```

### Connection Pooling

```python
# In superset_config.py
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
}
```

---

## Security Best Practices

### 1. Change Default Passwords

```bash
# Update .env with strong passwords
SUPERSET_POSTGRES_PASSWORD=$(openssl rand -base64 32)
SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
SUPERSET_GUEST_TOKEN_SECRET=$(openssl rand -base64 42)
```

### 2. Restrict CORS

```python
# In superset_config.py
CORS_OPTIONS = {
    'supports_credentials': True,
    'origins': ['https://your-domain.com']
}
```

### 3. Enable HTTPS

```nginx
# Nginx configuration
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://localhost:8088;
    }
}
```

### 4. Firewall Configuration

```bash
# Allow only necessary ports
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

---

## Monitoring

### Docker Health Checks

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' superset-postgres
docker inspect --format='{{.State.Health.Status}}' superset-base
```

### System Resources

```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check Docker container stats
docker stats
```

### Log Rotation

```bash
# Configure Docker log rotation
cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

systemctl restart docker
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Container exits immediately | Check logs: `docker-compose logs superset` |
| Database connection failed | Wait for PostgreSQL: `docker exec postgres pg_isready` |
| Plugin not showing | Rebuild: `docker-compose build --no-cache superset` |
| Port already in use | Kill process or change port in docker-compose.yml |
| Permission denied | Fix ownership: `chown -R $USER:$USER ~/alpha-sports-dashboard` |

### Debug Mode

```bash
# Enable debug in docker-entrypoint.sh
exec superset run -p 8088 --with-threads --reload --debug
```

---

## Maintenance

### Daily Tasks

- [ ] Check container status: `docker-compose ps`
- [ ] Review logs for errors: `docker-compose logs | grep -i error`
- [ ] Check disk space: `df -h`

### Weekly Tasks

- [ ] Backup database: `pg_dump superset > backup.sql`
- [ ] Clean up Docker: `docker system prune -a`
- [ ] Review security logs

### Monthly Tasks

- [ ] Update Docker images
- [ ] Rotate secrets
- [ ] Review and update security group rules

---

## Support

For issues:

1. Check logs: `docker-compose logs -f superset`
2. Verify ports: `ss -tlnp | grep :8088`
3. Test database: `docker exec -it superset-postgres psql -U superset -d superset`
4. Review docs: `docs/deployment/`

---

**Version:** 1.0
**Last Updated:** 2026-03-15
**Maintainer:** Platform Team
