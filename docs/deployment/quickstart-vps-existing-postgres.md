# Quick Deploy to VPS with Existing PostgreSQL

This guide assumes you have:
- PostgreSQL already running on your VPS
- Docker installed on your VPS
- SSH access to your VPS
- Superset database created on VPS PostgreSQL

---

## Step 1: Build Docker Image on Your Laptop

```bash
cd /Users/alan/dashboard

# Build the image (adjust the name)
docker build -f Dockerfile.superset -t superset-custom .
```

---

## Step 2: Transfer Image to VPS

```bash
# Use the simplified transfer script
./scripts/deploy/push-to-vps.sh \
    --host YOUR_VPS_IP \
    --user ubuntu \
    --name superset-custom
```

**Or manually:**
```bash
# Save image
docker save superset-custom -o superset-custom.tar

# Transfer to VPS
scp superset-custom.tar ubuntu@YOUR_VPS_IP:~/

# SSH to VPS and load
ssh ubuntu@YOUR_VPS_IP
docker load -i superset-custom.tar
```

---

## Step 3: Create docker-compose.yml on VPS

```bash
ssh ubuntu@YOUR_VPS_IP
cd ~

cat > docker-compose.yml << 'EOF'
services:
  superset:
    image: superset-custom
    ports:
      - "8088:8088"
    environment:
      # Database settings - point to your existing PostgreSQL
      SUPERSET_DB_HOST: localhost
      SUPERSET_DB_PORT: 5432
      SUPERSET_DB_USER: superset
      SUPERSET_DB_PASS: YOUR_POSTGRES_PASSWORD
      SUPERSET_DB_NAME: superset
      # Secrets
      SUPERSET_SECRET_KEY: $(openssl rand -base64 42 | head -c 42)
      SUPERSET_GUEST_TOKEN_SECRET: $(openssl rand -base64 42 | head -c 42)
    command: superset run -p 8088 --host=0.0.0.0
    restart: unless-stopped
EOF
```

---

## Step 4: Initialize Database on VPS

```bash
# Run migrations
docker exec -it superset-superset-1 superset db upgrade

# Initialize roles and permissions
docker exec -it superset-superset-1 superset init

# Create admin user
docker exec -it superset-superset-1 superset fab create-admin \
    --username admin \
    --email admin@example.com \
    --password admin
```

---

## Step 5: Start Superset

```bash
docker-compose up -d
docker-compose logs -f superset
```

---

## Step 6: Access Your Dashboard

Open: `http://YOUR_VPS_IP:8088`

Default login:
- **Username:** `admin`
- **Password:** `admin`

---

## Troubleshooting

### Database Connection Failed
```bash
# Verify PostgreSQL is running on VPS
docker exec -it superset-superset-1 superset db upgrade

# Check if PostgreSQL is accessible
docker exec -it superset-superset-1 psql -h localhost -U superset -d superset -c "SELECT 1"
```

### Port Already in Use
```bash
# Check what's using port 8088
docker ps
# Stop any conflicting container
docker stop old-container
```

### Image Not Found
```bash
# Verify image is loaded
docker images | grep superset-custom
```

---

## Quick Commands

```bash
# Restart Superset
docker-compose restart

# View logs
docker-compose logs -f

# Stop Superset
docker-compose down

# Update image (transfer again)
./scripts/deploy/push-to-vps.sh --host YOUR_VPS_IP --name superset-custom
docker-compose down
docker-compose up -d
```
