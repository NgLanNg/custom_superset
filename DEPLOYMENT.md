# Alibaba Cloud Deployment Guide for Custom Superset

This guide covers deploying the Custom Superset dashboard (with Scenario Planning plugin) to Alibaba Cloud LightHouse.

## Prerequisites

- Alibaba Cloud LightHouse instance (Ubuntu 22.04 LTS recommended)
- 4+ CPU, 8+ GB RAM
- Docker installed
- Docker Compose installed
- Open port 8088 in security group

## Quick Start

### 1. Prepare Your Server

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

### 2. Set Environment Variables

```bash
# Create .env file in the project directory
cat > .env << EOF
# PostgreSQL Configuration
SUPERSET_POSTGRES_PASSWORD=your_secure_password_here

# Secret Keys (generate with: openssl rand -base64 42)
SUPERSET_SECRET_KEY=your_secret_key_here
SUPERSET_GUEST_TOKEN_SECRET=your_guest_token_secret_here

# Database Configuration
SUPERSET_DB_HOST=postgres
SUPERSET_DB_PORT=5432
SUPERSET_DB_USER=superset
SUPERSET_DB_NAME=superset
EOF
```

### 3. Generate Database Initialization Scripts

The database will be created automatically by Docker. However, you need to initialize the scenario tables:

```bash
# Create the custom table for scenario equity share
docker exec -it superset-postgres psql -U superset -d superset << 'EOF'
-- Silver table for scenario equity share
CREATE TABLE IF NOT EXISTS silver_scenario_equity_share (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    bu TEXT NOT NULL,
    opu TEXT NOT NULL,
    year INTEGER NOT NULL,
    value REAL NOT NULL,
    scenario_id TEXT,
    user_email TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path TEXT
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_scenario_equity_unique
    ON silver_scenario_equity_share(scenario_name, opu, year, scenario_id, user_email);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
    ON silver_scenario_equity_share(scenario_name, bu, opu);

-- Seed data (optional)
INSERT INTO silver_scenario_equity_share
    (scenario_name, bu, opu, year, value, scenario_id, user_email)
VALUES
    ('existing_assets', 'LNGA', 'MLNG', 2025, 75.0, '', 'admin'),
    ('existing_assets', 'LNGA', 'LNGC2', 2025, 35.0, '', 'admin'),
    ('existing_assets', 'LNGA', 'LNGC3', 2025, 15.0, '', 'admin'),
    ('existing_assets', 'LNGA', 'ALNG', 2025, 55.0, '', 'admin')
ON CONFLICT DO NOTHING;
EOF
```

### 4. Build and Start Services

```bash
# Build the Docker images
docker-compose build superset

# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f superset
```

### 5. Initialize the Database

```bash
# Run migrations
docker exec -it superset-base superset db upgrade

# Create default roles and permissions
docker exec -it superset-base superset init

# Create admin user (if needed)
docker exec -it superset-base superset fab create-admin \
    --username admin \
    --email admin@example.com \
    --firstname Admin \
    --lastname User \
    --password admin
```

### 6. Access Superset

Open your browser and navigate to:

```
http://YOUR_SERVER_IP:8088
```

Login with your admin credentials (or the default admin user created above).

### 7. Verify the Custom Plugin

1. Go to **Dashboards** > **+ New Dashboard**
2. Click **+ Add Chart**
3. Look for **Scenario** in the chart list
4. Configure the chart with your scenario data

---

## Production Hardening

### 1. Enable HTTPS (Recommended)

 Obtain an SSL certificate (let's encrypt or Alibaba Cloud SSL):

```bash
# Option 1: Use Alibaba Cloud SSL certificate
# Option 2: Use Let's Encrypt with Nginx reverse proxy
```

### 2. Secure Secrets

Use Alibaba Cloud Secrets Manager for production:

```bash
# Store secrets in Alibaba Cloud Secrets Manager
# Retrieve at runtime via IAM role
```

### 3. Configure CORS

Update `superset_config.py` to restrict CORS origins:

```python
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['Content-Type', 'Authorization'],
    'resources': {
        '/api/*': {'origins': 'https://your-domain.com'}
    }
}
```

### 4. Database Connection Pooling

Adjust pool settings in `superset_config.py` based on your RDS instance:

```python
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
}
```

---

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs superset

# Check database connectivity
docker exec -it superset-base ping postgres
```

### Database connection failed

```bash
# Verify PostgreSQL is running
docker-compose ps

# Check PostgreSQL logs
docker-compose logs postgres

# Test connection manually
docker exec -it superset-postgres psql -U superset -d superset
```

### Plugin not showing in chart list

```bash
# Rebuild the frontend with the plugin
docker-compose down
docker-compose build superset
docker-compose up -d
```

### Permission denied errors

```bash
# Fix file permissions
docker exec -it superset-base chown -R superset:superset /app/superset_home
```

---

## maintenance

### Backup Database

```bash
# Backup PostgreSQL data
docker exec superset-postgres pg_dump -U superset superset > backup_$(date +%Y%m%d).sql

# Restore
psql -U superset -d superset < backup.sql
```

### Update Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build superset
docker-compose up -d
```

---

## File Summary

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines PostgreSQL and Superset services |
| `Dockerfile.superset` | Custom Superset image with plugin |
| `docker-entrypoint.sh` | Initialization script |
| `superset/superset_config.py` | Production configuration |
| `superset/superset/views/scenario_writeback.py` | Custom write-back API |
| `docker-entrypoint.sh` | Container entrypoint |

---

## Support

For issues or questions, check the logs:

```bash
docker-compose logs -f superset
```
