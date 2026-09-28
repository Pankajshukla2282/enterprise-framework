#!/usr/bin/env bash
set -euo pipefail
ACTION=check REGISTRY="${EMTAF_REGISTRY:-}" TAG="${EMTAF_IMAGE_TAG:-dev}"
while [[ $# -gt 0 ]]; do case "$1" in --action) ACTION="$2"; shift 2;; --registry) REGISTRY="$2"; shift 2;; --tag) TAG="$2"; shift 2;; *) echo "Unknown option $1"; exit 2;; esac; done
command -v docker >/dev/null || { echo 'Docker is required'; exit 1; }
case "$ACTION" in
 check) echo 'Local mode requires no registry login. Cloud mode uses EMTAF_REGISTRY and docker login.';;
 login) [[ -n "$REGISTRY" ]] || { echo '--registry required'; exit 1; }; docker login "$REGISTRY";;
 mirror-platform) [[ -n "$REGISTRY" ]] || { echo '--registry required'; exit 1; }; while IFS="|" read -r src dest; do docker pull "$src"; docker tag "$src" "$REGISTRY/$dest"; docker push "$REGISTRY/$dest"; done <<'EOF'
postgres:16-alpine|emtaf-postgres:16-alpine
redis:7-alpine|emtaf-redis:7-alpine
docker.redpanda.com/redpandadata/redpanda:v24.3.5|emtaf-redpanda:v24.3.5
EOF
 ;;
 push|build-and-push) [[ -n "$REGISTRY" ]] || { echo '--registry required'; exit 1; }; ./scripts/build.sh --mode cloud --registry "$REGISTRY" --tag "$TAG" --push;;
 *) echo 'Action must be check, login, push or build-and-push'; exit 2;; esac
