#!/bin/bash
# Docker Image Transfer Script
# Uploads a local Docker image to a remote server via scp

set -euo pipefail

# Configuration
REMOTE_USER="${REMOTE_USER:-ubuntu}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_PORT="${REMOTE_PORT:-22}"
IMAGE_NAME="${IMAGE_NAME:-}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"
COMPRESS="${COMPRESS:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Transfer a Docker image to a remote server.

Required Options:
  -h, --host HOST       Remote host (IP or hostname)
  -n, --name IMAGE      Docker image name (e.g., superset-custom)

Optional Options:
  -u, --user USER       Remote user (default: ubuntu)
  -p, --port PORT       SSH port (default: 22)
  -t, --tag TAG         Image tag (default: latest)
  -o, --output DIR      Output directory for tar file (default: current dir)
  -c, --compress        Enable gzip compression (default: true)
  -d, --dry-run         Show commands without executing
  --no-compress         Disable compression
  -f, --force           Overwrite existing remote file
  --push-registry REG   Also push to registry (registry:tag format)

Examples:
  $0 --host 192.168.1.100 --name superset-custom
  $0 -h your-server.com -u admin -n myapp --tag v1.0
  $0 -h 10.0.0.5 -n superset-custom --push-registry registry.example.com/myapp

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
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -c|--compress)
            COMPRESS=true
            shift
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --push-registry)
            PUSH_REGISTRY="$2"
            shift 2
            ;;
        --help|-help|-h)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required options
if [[ -z "$REMOTE_HOST" ]]; then
    log_error "Remote host is required. Use -h or --host"
    usage
fi

if [[ -z "$IMAGE_NAME" ]]; then
    log_error "Image name is required. Use -n or --name"
    usage
fi

# Set defaults
TARBALL_NAME="${IMAGE_NAME##*/}-${IMAGE_TAG}"
if [[ "$COMPRESS" == "true" ]]; then
    TARBALL_NAME="${TARBALL_NAME}.tar.gz"
else
    TARBALL_NAME="${TARBALL_NAME}.tar"
fi

LOCAL_TARBALL="${OUTPUT_DIR}/${TARBALL_NAME}"
REMOTE_TARBALL="/tmp/${TARBALL_NAME}"

# Function to run command
run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

# Main execution
main() {
    log_info "Starting Docker Image Transfer"
    log_info "  Local Image:  ${IMAGE_NAME}:${IMAGE_TAG}"
    log_info "  Remote Host:  ${REMOTE_USER}@${REMOTE_HOST}"
    log_info "  Remote Port:  ${REMOTE_PORT}"
    log_info "  Output File:  ${LOCAL_TARBALL}"

    # Verify Docker is running
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi

    # Verify image exists
    if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &> /dev/null; then
        log_error "Image ${IMAGE_NAME}:${IMAGE_TAG} not found"
        log_info "  Available images:"
        docker images --format "{{.Repository}}:{{.Tag}}" | sed 's/^/    /' || true
        exit 1
    fi

    # Step 1: Save image to tarball
    log_info "Step 1: Saving image to tarball..."
    if [[ "$COMPRESS" == "true" ]]; then
        run docker save "${IMAGE_NAME}:${IMAGE_TAG}" | gzip > "${LOCAL_TARBALL}"
    else
        run docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "${LOCAL_TARBALL}"
    fi

    FILE_SIZE=$(du -h "${LOCAL_TARBALL}" | cut -f1)
    log_info "  Created: ${LOCAL_TARBALL} (${FILE_SIZE})"

    # Step 2: Transfer to remote server
    log_info "Step 2: Transferring to remote server..."
    run rsync -P -e "ssh -p ${REMOTE_PORT}" "${LOCAL_TARBALL}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TARBALL}"
    log_info "  Transferred to: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TARBALL}"

    # Step 3: Load image on remote server
    log_info "Step 3: Loading image on remote server..."
    REMOTE_CMD="docker load -i ${REMOTE_TARBALL}"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} '${REMOTE_CMD}'"
    else
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "${REMOTE_CMD}"
    fi
    log_info "  Image loaded on remote server"

    # Step 4: Verify on remote
    log_info "Step 4: Verifying image on remote server..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} 'docker images | grep ${IMAGE_NAME}'"
    else
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "docker images | grep ${IMAGE_NAME}"
    fi

    # Step 5: Push to registry if specified
    if [[ -n "${PUSH_REGISTRY:-}" ]]; then
        log_info "Step 5: Pushing to registry..."
        REMOTE_REGISTRY="${PUSH_REGISTRY}"

        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REMOTE_REGISTRY} && docker push ${REMOTE_REGISTRY}'"
        else
            # Login to registry
            if [[ -n "${REGISTRY_USERNAME:-}" ]]; then
                ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "echo '\${REGISTRY_PASSWORD}' | docker login ${REMOTE_REGISTRY%%/*} -u ${REGISTRY_USERNAME} --password-stdin"
            fi

            # Tag and push
            ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REMOTE_REGISTRY}"
            ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "docker push ${REMOTE_REGISTRY}"

            log_info "  Pushed to: ${REMOTE_REGISTRY}"
        fi
    fi

    # Cleanup
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Step 6: Cleaning up..."
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_TARBALL}"
        log_info "  Remote tarball removed"
        log_info "  Local tarball can be removed: rm ${LOCAL_TARBALL}"
    fi

    # Summary
    echo ""
    log_info "========================================"
    log_info "Transfer Complete!"
    log_info "========================================"
    echo ""
    log_info "The image is now available on the remote server."
    echo ""
    log_info "To run on the remote server:"
    echo ""
    echo "  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}"
    echo "  docker run -d -p 8088:8088 ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""

    if [[ -n "${PUSH_REGISTRY:-}" ]]; then
        log_info "Or pull from registry:"
        echo ""
        echo "  docker pull ${REMOTE_REGISTRY}"
        echo "  docker run -d -p 8088:8088 ${REMOTE_REGISTRY}"
        echo ""
    fi
}

# Run main
main
