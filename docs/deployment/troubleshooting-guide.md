---
type: documentation
date: 2026-03-15
author: Deployment Guide
category: deployment
title: Deployment Troubleshooting Guide
version: 1.0
---

# Deployment Troubleshooting Guide

This guide covers common issues when deploying Custom Superset to Alibaba Cloud.

---

## Container Startup Issues

### Container Exits Immediately

**Symptom:**
```bash
docker-compose ps
# superset-base  Exit 1
```

**Fix:**
```bash
# Check logs
docker-compose logs superset

# Common causes:
# 1. Missing SUPERSET_SECRET_KEY
# 2. Database connection failed
# 3. Permission issues
```

### Container Restart Loop

**Symptom:**
```bash
docker-compose ps
# superset-base  Restarting
```

**Fix:**
```bash
# Check for recurring errors
docker-compose logs --tail=100 superset

# Common causes:
# 1. Database not ready (increase depends_on condition)
# 2. Database migrations failing
# 3. Config file syntax errors
```

---

## Database Connection Issues

### Could Not Connect to Server

**Symptom:**
```
sqlalchemy.exc.OperationalError: could not connect to server: Connection refused
```

**Fix:**
```bash
# Check if PostgreSQL is running
docker-compose ps

# Check PostgreSQL logs
docker-compose logs postgres

# Wait for PostgreSQL to be healthy
docker exec superset-postgres pg_isready -U superset

# Restart services if needed
docker-compose restart postgres
```

### Connection Refused on Port 5432

**Symptom:**
```
Connection refused on port 5432
```

**Fix:**
```bash
# Check PostgreSQL container logs
docker-compose logs postgres | grep -i "listener"

# Verify PostgreSQL is listening
docker exec -it superset-postgres netstat -tlnp | grep 5432

# Check firewall rules (if on host)
ufw status
```

---

## Superset Initialization Issues

### superset init Fails

**Symptom:**
```
superset init failed with error
```

**Fix:**
```bash
# Run migrations first
docker exec -it superset-base superset db upgrade

# Then initialize
docker exec -it superset-base superset init

# If still failing, check database schema
docker exec -it superset-postgres psql -U superset -d superset -c "\dt"
```

### Admin User Creation Fails

**Symptom:**
```
superset fab create-admin failed
```

**Fix:**
```bash
# Check if user already exists
docker exec -it superset-base superset fab create-admin \
    --username admin \
    --email admin@example.com \
    --password admin 2>&1 || echo "User may already exist"

# Or create via database directly
docker exec -it superset-postgres psql -U superset -d superset -c "
    INSERT INTO ab_user (first_name, last_name, username, password, active, email, excel, created_on, changed_on)
    VALUES ('Admin', 'User', 'admin', 'hashed_password', 1, 'admin@example.com', 1, now(), now());
"
```

---

## Plugin Not Showing

### Scenario Chart Not in Chart List

**Symptom:**
- Custom plugin not visible when creating charts

**Fix:**
```bash
# 1. Check plugin source is bundled
docker exec -it superset-base ls -la /app/superset-frontend/plugins/

# 2. Rebuild the frontend
docker-compose down
docker-compose build superset
docker-compose up -d

# 3. Check logs for build errors
docker-compose logs superset | grep -i "error"
```

### Module Not Found

**Symptom:**
```
ModuleNotFoundError: No module named 'plugin_chart_scenario'
```

**Fix:**
```bash
# The plugin needs to be registered in MainPreset.ts
# Check the MainPreset.ts file contains:
# import { ScenarioChartPlugin } from '@superset-ui/plugin-chart-scenario';
```

---

## Build Issues

### npm Build Failures

**Symptom:**
```
npm ERR! node scripts/build.js
```

**Fix:**
```bash
# Check Node.js version (needs v18+)
docker exec -it superset-base node --version

# Clear npm cache
docker-compose build superset --no-cache

# or manually clear cache
docker exec -it superset-base rm -rf /app/superset-frontend/plugins/plugin-chart-scenario/node_modules
```

### Missing Dependencies

**Symptom:**
```
ERROR in ./node_modules/some-package
```

**Fix:**
```bash
# Rebuild with fresh cache
docker system prune -a
docker-compose build superset
```

---

## File Permission Issues

### Permission Denied

**Symptom:**
```
Permission denied: /app/superset_home/cache
```

**Fix:**
```bash
# Fix ownership in container
docker exec -it superset-base chown -R superset:superset /app

# Or fix on host
chown -R $USER:$USER ~/superset-deploy
```

### Volume Mount Issues

**Symptom:**
```
ERROR: for superset  Cannot create container for service superset
```

**Fix:**
```bash
# Check directory exists and has correct permissions
ls -la ~/superset-deploy

# Fix permissions
chmod -R 755 ~/superset-deploy
chown -R $USER:$USER ~/superset-deploy
```

---

## Network Issues

### Port Already in Use

**Symptom:**
```
ERROR: for superset  Cannot start service superset: Ports are not available
```

**Fix:**
```bash
# Check what's using port 8088
lsof -i :8088
# or
ss -tlnp | grep :8088

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8089:8088"  # Map to different host port
```

### CORS Errors

**Symptom:**
```
CORS policy: No 'Access-Control-Allow-Origin' header
```

**Fix:**
```python
# Update superset_config.py
CORS_OPTIONS = {
    'supports_credentials': True,
    'origins': ['http://localhost:8088', 'http://localhost:9000']
}
```

---

## SSL/TLS Issues

### Certificate Verification Failed

**Symptom:**
```
CERTIFICATE_VERIFY_FAILED
```

**Fix:**
```bash
# For development, disable SSL verification
export PYTHONHTTPSVERIFY=0

# Or use proper certificates
# See HTTPS configuration guide
```

---

## Database Schema Issues

### Table Not Found

**Symptom:**
```
psycopg2.errors.UndefinedTable: relation "silver_scenario_equity_share" does not exist
```

**Fix:**
```bash
# Create the table
docker exec -i superset-postgres psql -U superset -d superset \
    -f /app/scripts/init_db_script/create_scenario_table.sql

# Verify table exists
docker exec -it superset-postgres psql -U superset -d superset \
    -c "\dt silver_scenario_equity_share"
```

### Column Missing

**Symptom:**
```
psycopg2.errors.UndefinedColumn: column "scenario_id" does not exist
```

**Fix:**
```bash
# Add missing column
docker exec -i superset-postgres psql -U superset -d superset -c "
    ALTER TABLE silver_scenario_equity_share
    ADD COLUMN IF NOT EXISTS scenario_id TEXT DEFAULT '';
"

# Verify
docker exec -it superset-postgres psql -U superset -d superset \
    -c "\d silver_scenario_equity_share"
```

---

## Configuration Issues

### Environment Variables Not Picking Up

**Symptom:**
- Changes to `.env` file not reflected

**Fix:**
```bash
# Stop and restart services
docker-compose down
docker-compose up -d

# Or reload
docker-compose reload
```

### Config File Syntax Errors

**Symptom:**
```
ConfigParseError: Failed to parse config
```

**Fix:**
```bash
# Validate Python syntax
docker exec -it superset-base python -m py_compile /app/superset_config.py

# Check for common errors:
# - Missing quotes around strings
# - Missing commas
# - Incorrect indentation
```

---

## Logging and Debugging

### Enable Debug Mode

```bash
# Modify docker-entrypoint.sh
exec superset run -p 8088 --host=0.0.0.0 --with-threads --reload
```

### View Logs in Real-time

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f superset
docker-compose logs -f postgres
```

### Get Container Shell

```bash
# Get bash shell in running container
docker exec -it superset-base bash
docker exec -it superset-postgres psql -U superset -d superset
```

---

## Alibaba Cloud Specific Issues

### Port Not Accessible

**Symptom:**
```
Connection refused from external IP
```

**Fix:**
```bash
# Check Alibaba Cloud security group rules
# Allow inbound traffic on port 8088

# Check if Superset is binding to 0.0.0.0
# Not 127.0.0.1 Only
docker exec -it superset-base netstat -tlnp | grep 8088
```

### Database Disk Full

**Symptom:**
```
no space left on device
```

**Fix:**
```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -a

# Or expand disk on Alibaba Cloud
```

---

## Performance Issues

### Slow Page Loads

**Symptom:**
- Dashboard takes >30 seconds to load

**Fix:**
```bash
# Check database performance
docker exec -it superset-postgres psql -U superset -d superset -c "
    SELECT pid, state, query, now() - query_start as duration
    FROM pg_stat_activity WHERE state != 'idle';
"

# Add database indexes if missing
docker exec -i superset-postgres psql -U superset -d superset -c "
    CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
    ON silver_scenario_equity_share(scenario_name, bu, opu);
"
```

### High Memory Usage

**Symptom:**
- Container killed due to OOM

**Fix:**
```yaml
# Add memory limits to docker-compose.yml
superset:
  deploy:
    resources:
      limits:
        memory: 4G
      reservations:
        memory: 2G
```

---

## Emergency Recovery

### Restore from Backup

```bash
# Stop services
docker-compose down

# Restore database
docker exec -i superset-postgres psql -U superset -d superset < backup.sql

# Restart
docker-compose up -d
```

### Fresh Start

```bash
# complete reset
docker-compose down -v
rm -rf volumes/*
docker-compose up -d --build
```

---

**Version:** 1.0
**Last Updated:** 2026-03-15
