# Superset Custom Image - Build Status

## Image Details

| Property | Value |
|----------|-------|
| **Image Name** | `localhost/superset-custom` |
| **Tag** | `latest` |
| **Size** | 979 MB |
| **Base** | `apache/superset:4.1.2` |
| **Built** | 2026-03-16 |

## What's Included

- Apache Superset 4.1.2
- Custom `superset_config_local.py` configuration
- Scenario Write-back API views
- Scenario Metadata API
- Custom Scenario Chart plugin (pre-built)
- SQL init scripts
- Custom entrypoint script
- `psycopg2-binary` for PostgreSQL connection

## Custom Files

1. **superset_config_local.py** - Custom configuration with PostgreSQL support
2. **scenario_writeback.py** - Write-back API for cell edits
3. **scenario_metadata.py** - Scenario lifecycle management API
4. **scenario.py** - Scenario view registration
5. **plugin-chart-scenario/** - Pre-built chart plugin (lib/ + esm/)

## Usage

### Transfer to VPS

```bash
# Transfer tarball to VPS
scp superset-custom.tar.gz ubuntu@YOUR_VPS_IP:~/

# On VPS
ssh ubuntu@YOUR_VPS_IP
docker load -i superset-custom.tar.gz
docker images
```

### Run on VPS

```bash
# Create docker-compose.yml
docker run -d -p 8088:8088 \
  -e SUPERSET_DB_HOST=localhost \
  -e SUPERSET_DB_PORT=5432 \
  -e SUPERSET_DB_USER=superset \
  -e SUPERSET_DB_PASS=YOUR_PASSWORD \
  -e SUPERSET_DB_NAME=superset \
  -e SUPERSET_SECRET_KEY=$(openssl rand -base64 42) \
  --name superset superset-custom
```

### Available Commands

```bash
# After container starts:
docker exec -it superset superset db upgrade
docker exec -it superset superset init
docker exec -it superset superset fab create-admin \
  --username admin --email admin@example.com --password admin
```

## Access

- **URL:** `http://YOUR_VPS_IP:8088`
- **Default Admin:** `admin / admin`

---

**Note:** The VPS must have PostgreSQL running with the Superset database created.
