#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-emtaf}"
if [[ "${1:-}" == "--purge" ]]; then kubectl -n "$NAMESPACE" delete deployment hotel-service --ignore-not-found; kubectl -n "$NAMESPACE" delete service hotel-service --ignore-not-found; else kubectl -n "$NAMESPACE" scale deployment/hotel-service --replicas=0; fi
