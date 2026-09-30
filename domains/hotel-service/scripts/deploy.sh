#!/usr/bin/env bash
set -euo pipefail
ENVIRONMENT="${1:-dev}"; MODE="${IMAGE_MODE:-local}"; REGISTRY="${REGISTRY:-}"; TAG="${TAG:-dev}"; NAMESPACE="${NAMESPACE:-emtaf}"
command -v helm >/dev/null || { echo 'helm is required'; exit 1; }
CHART="$(cd "$(dirname "$0")/../helm" && pwd)"
if [[ "$MODE" == cloud ]]; then [[ -n "$REGISTRY" ]] || { echo 'REGISTRY is required in cloud mode'; exit 1; }; REPO="${REGISTRY%/}/emtaf-hotel-service"; else REPO="emtaf-hotel-service"; fi
helm upgrade --install "emtaf-hotel" "$CHART" -n "$NAMESPACE" --create-namespace --set image.repository="$REPO" --set image.tag="$TAG" --set imagePullPolicy=IfNotPresent
