#!/bin/bash
# Docker Image Transfer Script - Simplified for existing PostgreSQL
# Uploads a local Docker image to a remote server via ssh

set -euo pipefail

# Configuration
REMOTE_USER="${REMOTE_USER:-ubuntu}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_PORT="${REMOTE_PORT:-22}"
IMAGE_NAME="${IMAGE_NAME:-}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
COMPRESS="${COMPRESS:-true}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Transfer Docker image to remote VPS for Superset deployment.
Uses existing PostgreSQL on the VPS (no database container needed).

Required Options:
  -h, --host HOST       Remote VPS host (IP or hostname)
  -n, --name IMAGE      Docker image name (e.g., superset-custom)

Optional Options:
  -u, --user USER       Remote user (default: ubuntu)
  -p, --port PORT       SSH port (default: 22)
  -t, --tag TAG         Image tag (default: latest)
  --no-compress         Disable compression
  --dry-run             Show commands without executing

Examples:
  $0 --host 192.168.1.100 --name superset-custom
  $0 -h your-vps.com -u root -n superset-custom

Environment Variables:
  REMOTE_USER, REMOTE_HOST, IMAGE_NAME - can be set instead of flags

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            REMOTE_HOST="$2"
            shift 2
            ;;
        -u|--user)
            REMOTE_USER="$2"
            shift 2
            ;;
        -p|--port)
            REMOTE_PORT="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate
if [[ -z "$REMOTE_HOST" ]]; then
    log_error "Remote host is required. Use -h or --host"
    usage
fi

if [[ -z "$IMAGE_NAME" ]]; then
    log_error "Image name is required. Use -n or --name"
    usage
fi

# File naming
TARBALL_NAME="${IMAGE_NAME##*/}-${IMAGE_TAG}"
if [[ "$COMPRESS" == "true" ]]; then
    TARBALL_NAME="${TARBALL_NAME}.tar.gz"
else
    TARBALL_NAME="${TARBALL_NAME}.tar"
fi

REMOTE_TARBALL="/tmp/${TARBALL_NAME}"

run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

main() {
    log_info "========================================"
    log_info "Docker Image Transfer to VPS"
    log_info "========================================"
    log_info "  Local Image:  ${IMAGE_NAME}:${IMAGE_TAG}"
    log_info "  Remote Host:  ${REMOTE_USER}@${REMOTE_HOST}"
    log_info "  Remote Port:  ${REMOTE_PORT}"
    log_info "  Remote DB:    Using existing PostgreSQL on VPS"
    echo ""

    # Verify Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    # Verify image exists
    if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &> /dev/null; then
        log_error "Image ${IMAGE_NAME}:${IMAGE_TAG} not found locally"
        log_info "  Run: docker build -f Dockerfile.superset -t ${IMAGE_NAME} ."
        exit 1
    fi

    # Step 1: Save image
    log_info "Step 1: Saving image to tarball..."
    if [[ "$COMPRESS" == "true" ]]; then
        docker save "${IMAGE_NAME}:${IMAGE_TAG}" | gzip > "/tmp/${TARBALL_NAME}"
    else
        docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "/tmp/${TARBALL_NAME}"
    fi
    FILE_SIZE=$(du -h "/tmp/${TARBALL_NAME}" | cut -f1)
    log_info "  Created: /tmp/${TARBALL_NAME} (${FILE_SIZE})"

    # Step 2: Transfer
    log_info "Step 2: Transferring to VPS..."
    if [[ "$DRY_RUN" != "true" ]]; then
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p /tmp"
        scp -P "${REMOTE_PORT}" "/tmp/${TARBALL_NAME}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TARBALL}"
    else
        echo -e "${YELLOW}[DRY-RUN]${NC} scp /tmp/${TARBALL_NAME} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TARBALL}"
    fi
    log_info "  Transferred to: ${REMOTE_TARBALL}"

    # Step 3: Load on VPS
    log_info "Step 3: Loading image on VPS..."
    if [[ "$COMPRESS" == "true" ]]; then
        REMOTE_CMD="gunzip -c ${REMOTE_TARBALL} | docker load"
    else
        REMOTE_CMD="docker load -i ${REMOTE_TARBALL}"
    fi
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "$REMOTE_CMD"
    log_info "  Image loaded on VPS"

    # Verify
    log_info "Step 4: Verifying..."
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "docker images | grep ${IMAGE_NAME}"

    # Cleanup
    if [[ "$DRY_RUN" != "true" ]]; then
        rm -f "/tmp/${TARBALL_NAME}"
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_TARBALL}"
    fi

    # Summary
    echo ""
    log_info "========================================"
    log_info "Transfer Complete!"
    log_info "========================================"
    echo ""
    log_info "On your VPS, create docker-compose.yml:"
    echo ""
    cat << 'COMPOSE'
services:
  superset:
    image: superset-custom
    ports:
      - "8088:8088"
    environment:
      SUPERSET_DB_HOST: localhost
      SUPERSET_DB_PORT: 5432
      SUPERSET_DB_USER: superset
      SUPERSET_DB_PASS: YOUR_PASSWORD
      SUPERSET_DB_NAME: superset
      SUPERSET_SECRET_KEY: YOUR_SECRET_KEY
    command: superset run -p 8088 --host=0.0.0.0
COMPOSE
    echo ""
    log_info "Then run on VPS:"
    echo ""
    echo "  cd ~"
    echo "  docker-compose up -d"
    echo "  docker-compose logs -f superset"
    echo ""
    log_info "Default admin: admin / admin"
    echo ""
}

main
