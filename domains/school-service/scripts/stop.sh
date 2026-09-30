#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-emtaf}"
if [[ "${1:-}" == "--purge" ]]; then kubectl -n "$NAMESPACE" delete deployment school-service --ignore-not-found; kubectl -n "$NAMESPACE" delete service school-service --ignore-not-found; else kubectl -n "$NAMESPACE" scale deployment/school-service --replicas=0; fi
