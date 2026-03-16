# Docker Image Transfer Scripts

This directory contains scripts for transferring and deploying Docker images to remote servers.

## Scripts

### 1. `push-to-remote.sh` - Upload Local Image to Remote Server

Transfers a Docker image from your local machine to a remote server via `docker save` / `ssh` / `docker load`.

**Usage:**
```bash
# Basic usage
./push-to-remote.sh --host 192.168.1.100 --name superset-custom

# With custom user and port
./push-to-remote.sh -h your-server.com -u ubuntu -n superset-custom -p 22

# Push to registry after transfer
./push-to-remote.sh -h 192.168.1.100 -n superset-custom \
    --push-registry registry.cn-hangzhou.aliyuncs.com/your-namespace/superset-custom

# Dry run (show commands without executing)
./push-to-remote.sh -h 192.168.1.100 -n superset-custom --dry-run
```

**Options:**
- `-h, --host HOST` - Remote host (required)
- `-n, --name IMAGE` - Docker image name (required)
- `-u, --user USER` - Remote user (default: ubuntu)
- `-p, --port PORT` - SSH port (default: 22)
- `-t, --tag TAG` - Image tag (default: latest)
- `--compress` - Enable gzip compression (default)
- `--no-compress` - Disable compression
- `--push-registry REGISTRY` - Also push to registry after transfer
- `--dry-run` - Show commands without executing

**Environment Variables:**
- `REMOTE_USER` - Remote user
- `REMOTE_HOST` - Remote host
- `IMAGE_NAME` - Image name

**Example:**
```bash
export REMOTE_HOST=192.168.1.100
export IMAGE_NAME=superset-custom

# Transfer the image
./push-to-remote.sh

# On remote server, run:
# docker run -d -p 8088:8088 superset-custom
```

---

### 2. `deploy-remote.sh` - Full Remote Deployment

Pulls/builds image on remote server and starts Docker Compose services.

**Usage:**
```bash
# Pull existing image and start
./deploy-remote.sh --host 192.168.1.100 --name superset-custom --pull-image

# Build on remote server
./deploy-remote.sh -h 192.168.1.100 -n superset-custom --build-image

# Dry run
./deploy-remote.sh -h 192.168.1.100 -n superset-custom --dry-run
```

**Options:**
- `-h, --host HOST` - Remote host (required)
- `-n, --name IMAGE` - Docker image name (required)
- `--pull-image` - Pull image from registry
- `--build-image` - Build image on remote server
- `--start-only` - Only start services (assume image exists)

**This script also:**
1. Creates project directory on remote
2. Transfers docker-compose.yml and related files
3. Handles image (pull/build/load)
4. Starts services with docker-compose
5. Runs database migrations
6. Shows access URLs and default credentials

---

## Quick Start

### Push Image to Alibaba Cloud VM

```bash
# 1. On your laptop, build the image
docker build -f Dockerfile.superset -t superset-custom .

# 2. Transfer to your Alibaba Cloud VM
./scripts/deploy/push-to-remote.sh \
    --host YOUR_SERVER_IP \
    --user ubuntu \
    --name superset-custom

# 3. On the VM, run the container
ssh -i your-key.pem ubuntu@YOUR_SERVER_IP
cd /path/to/project
docker run -d -p 8088:8088 superset-custom
```

### Full Remote Deployment

```bash
# 1. Ensure docker-compose.yml is in the current directory
ls docker-compose.yml

# 2. Deploy to server
./scripts/deploy/deploy-remote.sh \
    --host YOUR_SERVER_IP \
    --user ubuntu \
    --name superset-custom \
    --pull-image
```

---

## Prerequisites

### On Your Laptop:
- Docker installed
- SSH access to remote server
- Network access to remote server

### On Remote Server:
- Docker installed
- Docker Compose installed
-ufficient disk space for Docker image

---

## Troubleshooting

### SSH Connection Failed
```bash
ssh -p 22 user@host
# Check SSH key, firewall, security group rules
```

### Image Not Found
```bash
# List local images
docker images | grep superset-custom

# Build if missing
docker build -f Dockerfile.superset -t superset-custom .
```

### Permission Denied on Remote
```bash
# Verify docker group membership on remote
ssh user@host "groups"

# Add to docker group if needed
ssh user@host "sudo usermod -aG docker $USER"
```

### Port Already in Use
```bash
# Check and kill existing containers
ssh user@host "docker ps -a"
ssh user@host "docker stop container-name"
ssh user@host "docker rm container-name"
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REMOTE_USER` | Remote SSH user | ubuntu |
| `REMOTE_HOST` | Remote host/IP | - (required) |
| `REMOTE_PORT` | SSH port | 22 |
| `IMAGE_NAME` | Docker image name | - (required) |
| `IMAGE_TAG` | Image tag | latest |

---

**Version:** 1.0
**Last Updated:** 2026-03-15
