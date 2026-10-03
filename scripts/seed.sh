#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-emtaf}"
OVERLAY="${1:-dev}"
case "$OVERLAY" in sandbox) NAMESPACE=emtaf-training ;; dev|staging|prod) ;;  *) echo "Usage: $0 [dev|staging|prod]" >&2; exit 2;; esac
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
POD="$(kubectl -n "$NAMESPACE" get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')"
[[ -n "$POD" ]] || { echo "PostgreSQL pod not found in namespace $NAMESPACE" >&2; exit 1; }
kubectl -n "$NAMESPACE" wait --for=condition=Ready "pod/$POD" --timeout=180s >/dev/null
for seed in "$ROOT_DIR"/scripts/seed/seed-*.sql; do
  echo "Applying $(basename "$seed")..."
  kubectl -n "$NAMESPACE" exec -i "$POD" -- env PGPASSWORD="${POSTGRES_PASSWORD:-emtaf-dev}" psql -U emtaf -d emtaf -v ON_ERROR_STOP=1 < "$seed"
done
echo "Idempotent EMTAF sample data seeded into $NAMESPACE ($OVERLAY)."
