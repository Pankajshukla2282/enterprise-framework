#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-emtaf}"
if [[ "${1:-}" == "--purge" ]]; then kubectl -n "$NAMESPACE" delete deployment college-service --ignore-not-found; kubectl -n "$NAMESPACE" delete service college-service --ignore-not-found; else kubectl -n "$NAMESPACE" scale deployment/college-service --replicas=0; fi
