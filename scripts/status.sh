#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-emtaf}"
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
kubectl -n "$NAMESPACE" get deploy,svc,job,pods -o wide
