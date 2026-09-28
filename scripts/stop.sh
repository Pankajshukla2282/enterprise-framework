#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${1:-dev}"
NAMESPACE="${NAMESPACE:-emtaf}"
PURGE_DATA="false"
if [[ "${2:-}" == "--purge-data" ]]; then PURGE_DATA="true"; fi
case "$OVERLAY" in dev|staging|prod) ;; *) echo "Usage: $0 [dev|staging|prod] [--purge-data]" >&2; exit 2;; esac
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }

# Idempotent teardown. By default the namespace is retained and only workloads are
# removed. --purge-data deletes the namespace, including PVCs created inside it.
kubectl delete -k "$ROOT_DIR/infra/kubernetes/overlays/$OVERLAY" --ignore-not-found=true >/dev/null 2>&1 || true
kubectl -n "$NAMESPACE" delete job emtaf-migrations --ignore-not-found=true >/dev/null 2>&1 || true

if [[ "$PURGE_DATA" == "true" ]]; then
  kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
  echo "EMTAF $OVERLAY torn down and namespace/data purged."
else
  echo "EMTAF $OVERLAY workloads torn down; namespace/data retained."
  echo "Use '$0 $OVERLAY --purge-data' to remove the namespace and persistent data."
fi
