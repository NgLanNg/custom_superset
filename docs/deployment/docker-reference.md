---
type: documentation
date: 2026-03-15
author: Deployment Guide
category: deployment
title: Docker Deployment Reference
version: 1.0
---

# Docker Deployment Files Reference

This document describes the Docker deployment files for the Custom Superset dashboard.

---

## File Overview

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines PostgreSQL and Superset services |
| `Dockerfile.superset` | Custom Superset image with plugin pre-built |
| `docker-entrypoint.sh` | Container initialization script |
| `superset_config.py` | Production configuration |
| `.env` | Environment variables (not committed) |

---

## docker-compose.yml

### Services

#### PostgreSQL

```yaml
postgres:
  image: postgres:16-alpine
  container_name: superset-postgres
  environment:
    POSTGRES_USER: superset
    POSTGRES_PASSWORD: ${SUPERSET_POSTGRES_PASSWORD:-superset}
    POSTGRES_DB: superset
  ports:
    - "5432:5432"
  volumes:
    - pgdata:/var/lib/postgresql/data
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U superset"]
    interval: 5s
    timeout: 3s
    retries: 5
  restart: unless-stopped
```

#### Superset

```yaml
superset:
  build:
    context: .
    dockerfile: Dockerfile.superset
  container_name: superset-base
  ports:
    - "8088:8088"
  environment:
    SUPERSET_DB_HOST: postgres
    SUPERSET_DB_PORT: 5432
    SUPERSET_DB_USER: superset
    SUPERSET_DB_PASS: ${SUPERSET_POSTGRES_PASSWORD:-superset}
    SUPERSET_DB_NAME: superset
    SUPERSET_SECRET_KEY: ${SUPERSET_SECRET_KEY:-change-me}
    SUPERSET_GUEST_TOKEN_SECRET: ${SUPERSET_GUEST_TOKEN_SECRET:-change-me}
  depends_on:
    postgres:
      condition: service_healthy
  restart: unless-stopped
```

---

## Dockerfile.superset

### Build Stages

1. **Base Image**: `apache/superset:5.1.0`
2. **Copy Config**: `superset_config.py`, `docker-entrypoint.sh`
3. **Copy Views**: `scenario_writeback.py`, `scenario_metadata.py`, `scenario.py`
4. **Copy Plugin**: `plugin-chart-scenario/`
5. **Copy Scripts**: `scripts/init_db_script/`
6. **Build Plugin**: `npm install && npm run build`
7. **Install Python Packages**: `psycopg2-binary`, `sqlalchemy`
8. **Set Entrypoint**: `/entrypoint.sh`

### Docker Build Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPERSET_SECRET_KEY` | Yes | - | Session signing key |
| `SUPERSET_GUEST_TOKEN_SECRET` | Yes | - | Embedded SDK auth |

---

## docker-entrypoint.sh

### Initialization Steps

```bash
#!/bin/bash
set -e

echo "Starting Superset with custom configuration..."

# 1. Run database migrations
superset db upgrade

# 2. Create default roles and permissions
superset init

# 3. Load example data (if configured)
if [ "${LOAD_EXAMPLES:-false}" = "true" ]; then
    superset load_examples
fi

# 4. Register custom views
echo "Registering custom views..."

# 5. Start Superset server
exec superset run -p 8088 --host=0.0.0.0 --with-threads --reload --debugger
```

---

## superset_config.py

### Key Configuration Sections

#### 1. Secret Key

```python
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")
```

#### 2. Database URI

```python
SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"
```

#### 3. CORS

```python
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['Content-Type', 'Authorization', 'X-CSRFToken'],
    'resources': {'*': {'origins': '*'}},
}
```

#### 4. Feature Flags

```python
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "EMBEDDABLE_CHARTS": True,
    "AG_GRID_TABLE_ENABLED": True,
    "DASHBOARD_RBAC": True,
}
```

---

## Environment Variables Reference

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `SUPERSET_POSTGRES_PASSWORD` | Yes | `MySecurePass123!` | PostgreSQL password |
| `SUPERSET_SECRET_KEY` | Yes | `$(openssl rand -base64 42)` | Session signing |
| `SUPERSET_GUEST_TOKEN_SECRET` | Yes | `$(openssl rand -base64 42)` | Guest token JWT |
| `SUPERSET_DB_HOST` | No | `postgres` | Database hostname |
| `SUPERSET_DB_PORT` | No | `5432` | Database port |
| `SUPERSET_DB_USER` | No | `superset` | Database user |
| `SUPERSET_DB_NAME` | No | `superset` | Database name |
| `LOAD_EXAMPLES` | No | `false` | Load Superset examples |

---

## Quick Start Commands

```bash
# Create environment file
cat > .env << 'EOF'
SUPERSET_POSTGRES_PASSWORD=your_secure_password
SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
SUPERSET_GUEST_TOKEN_SECRET=$(openssl rand -base64 42)
EOF

# Build and start
docker-compose build superset
docker-compose up -d

# Initialize database
docker exec -it superset-base superset db upgrade
docker exec -it superset-base superset init

# Create admin user
docker exec -it superset-base superset fab create-admin \
    --username admin --email admin@example.com \
    --password admin
```

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using port 8088
lsof -i :8088
# or
ss -tlnp | grep :8088

# Change port in docker-compose.yml
ports:
  - "8089:8088"  # Host:Container
```

### Build Failed

```bash
# Clean and rebuild
docker-compose down
docker system prune -a
docker-compose build superset
```

### Volume Permission Issues

```bash
# Fix permissions
chmod -R 777 ~/superset-deploy
# or
chown -R $USER:$USER ~/superset-deploy
```

---

## Production Checklist

- [ ] Set strong `SUPERSET_SECRET_KEY`
- [ ] Set strong `SUPERSET_POSTGRES_PASSWORD`
- [ ] Configure HTTPS with Nginx
- [ ] Set up firewall (allow only 80, 443, 22)
- [ ] Enable PostgreSQL authentication
- [ ] Configure CORS with specific domains
- [ ] Set up log rotation
- [ ] Configure monitoring/alerting
- [ ] Set up database backups
- [ ] Enable container health checks

---

**Version:** 1.0
**Last Updated:** 2026-03-15
