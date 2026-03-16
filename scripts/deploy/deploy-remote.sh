#!/bin/bash
# Docker Image Pull and Run Script
# Pulls a Docker image from remote server or registry and starts services

set -euo pipefail

# Configuration
REMOTE_USER="${REMOTE_USER:-ubuntu}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_PORT="${REMOTE_PORT:-22}"
IMAGE_NAME="${IMAGE_NAME:-}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-superset-base}"
PROJECT_DIR="${PROJECT_DIR:-/opt/superset}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

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

Deploy Docker image to remote server and start services.

Required Options:
  -h, --host HOST       Remote host (IP or hostname)
  -n, --name IMAGE      Docker image name (e.g., superset-custom)

Optional Options:
  -u, --user USER       Remote user (default: ubuntu)
  -p, --port PORT       SSH port (default: 22)
  -t, --tag TAG         Image tag (default: latest)
  -c, --container NAME  Container name (default: superset-base)
  -d, --dir DIR         Project directory on remote (default: /opt/superset)
  -f, --compose FILE    docker-compose file (default: docker-compose.yml)
  --pull-image          Pull fresh image from registry
  --no-cache            Don't use build cache when building
  --build-image         Build image on remote server
  --start-only          Only start services, don't pull/build
  -d, --dry-run         Show commands without executing

Examples:
  $0 --host 192.168.1.100 --name superset-custom
  $0 -h server.com -u admin -n myapp --pull-image
  $0 -h 10.0.0.5 -n superset-custom --build-image

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
        -c|--container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -d|--dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        -f|--compose)
            COMPOSE_FILE="$2"
            shift 2
            ;;
        --pull-image)
            PULL_IMAGE=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --build-image)
            BUILD_IMAGE=true
            shift
            ;;
        --start-only)
            START_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
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

# Default behavior: pull if no build flag specified, but only if no image specified
if [[ -z "${PULL_IMAGE:-}" ]] && [[ -z "${BUILD_IMAGE:-}" ]] && [[ -z "${START_ONLY:-}" ]]; then
    # Check if this is a public image
    if docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &> /dev/null; then
        log_info "Local image found. Using local image."
        USE_LOCAL=true
    else
        log_info "No local image found. Will pull from registry."
        PULL_IMAGE=true
    fi
fi

run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

main() {
    log_info "Starting Docker Deployment"
    log_info "  Remote Host:  ${REMOTE_USER}@${REMOTE_HOST}"
    log_info "  Project Dir:  ${PROJECT_DIR}"
    log_info "  Image:        ${IMAGE_NAME}:${IMAGE_TAG}"

    # Validate SSH connection
    log_info "Verifying SSH connection..."
    if [[ "$DRY_RUN" != "true" ]]; then
        ssh -p "${REMOTE_PORT}" -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "echo SSH connection successful" || {
            log_error "SSH connection failed"
            log_info "  Try: ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}"
            exit 1
        }
    fi

    # Step 1: Prepare remote directory
    log_info "Step 1: Preparing remote directory..."
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "mkdir -p ${PROJECT_DIR} && cd ${PROJECT_DIR} && ls -la"

    # Step 2: Transfer project files (docker-compose.yml, scripts, config)
    log_info "Step 2: Transferring project files..."
    PROJECT_FILES=("docker-compose.yml" "docker-entrypoint.sh" "superset_config.py" "scripts/init_db_script")

    for file in "${PROJECT_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}[DRY-RUN]${NC} rsync -P -e \"ssh -p ${REMOTE_PORT}\" $file ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/"
            else
                rsync -P -e "ssh -p ${REMOTE_PORT}" "$file" "${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/" 2>/dev/null || true
            fi
        else
            log_warn "  File not found (optional): $file"
        fi
    done

    # Step 3: Handle Docker image
    if [[ -n "${USE_LOCAL:-}" ]]; then
        # Method 1: Use local image via save/load
        log_info "Step 3: Loading local image to remote server..."

        # Save and transfer in one pipeline
        REMOTE_CMD="docker load"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} docker save ${IMAGE_NAME}:${IMAGE_TAG} | gzip | ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} '${REMOTE_CMD}'"
        else
            docker save "${IMAGE_NAME}:${IMAGE_TAG}" | gzip | ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "${REMOTE_CMD}"
        fi

    elif [[ -n "${PULL_IMAGE:-}" ]]; then
        # Method 2: Pull from registry
        log_info "Step 3: Pulling image from registry..."
        if [[ -n "${REGISTRY_PASSWORD:-}" ]]; then
            # Login if credentials provided
            if [[ "$DRY_RUN" != "true" ]]; then
                ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
                    "echo '\${REGISTRY_PASSWORD}' | docker login ${IMAGE_NAME%%/*} -u \${REGISTRY_USERNAME} --password-stdin 2>/dev/null || true"
            fi
        fi
        run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
            "cd ${PROJECT_DIR} && docker pull ${IMAGE_NAME}:${IMAGE_TAG}"

    elif [[ -n "${BUILD_IMAGE:-}" ]]; then
        # Method 3: Build on remote server
        log_info "Step 3: Building image on remote server..."
        BUILD_CMD="cd ${PROJECT_DIR} && docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile.superset ."
        if [[ -n "${NO_CACHE:-}" ]]; then
            BUILD_CMD="${BUILD_CMD} --no-cache"
        fi
        run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "$BUILD_CMD"
    fi

    # Step 4: Start services
    log_info "Step 4: Starting services..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} 'cd ${PROJECT_DIR} && docker-compose up -d'"
    else
        ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
            "cd ${PROJECT_DIR} && docker-compose up -d"
    fi

    # Step 5: Check status
    log_info "Step 5: Checking service status..."
    sleep 5
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "cd ${PROJECT_DIR} && docker-compose ps"

    # Step 6: Database initialization
    log_info "Step 6: Initializing database..."
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "cd ${PROJECT_DIR} && docker-compose exec -T postgres pg_isready -U superset"

    # Run migrations
    log_info "Running database migrations..."
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "cd ${PROJECT_DIR} && docker-compose exec -T superset-base superset db upgrade"

    # Initialize
    log_info "Initializing Superset..."
    run ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
        "cd ${PROJECT_DIR} && docker-compose exec -T superset-base superset init"

    log_info "========================================"
    log_info "Deployment Complete!"
    log_info "========================================"
    echo ""
    log_info "Services are running on ${REMOTE_HOST}"
    echo ""
    log_info "Access URLs:"
    echo "  - Superset:   http://${REMOTE_HOST}:8088"
    echo "  - PostgreSQL: ${REMOTE_HOST}:5432"
    echo ""
    log_info "Quick commands:"
    echo "  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}"
    echo "  cd ${PROJECT_DIR}"
    echo "  docker-compose ps"
    echo "  docker-compose logs -f superset-base"
    echo ""
    log_info "Default credentials (after init):"
    echo "  Username: admin"
    echo "  Password: admin"
    echo ""
    log_info "To stop services: docker-compose down"
    log_info "To restart:       docker-compose restart"
    echo ""
}

main
