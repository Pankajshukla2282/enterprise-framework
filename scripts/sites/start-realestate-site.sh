#!/usr/bin/env bash
# Starter for realestate-site: port-forwards realestate-service and runs the site.
set -euo pipefail
SITE_PORT="${SITE_PORT:-3002}"
API_PORT="${API_PORT:-8080}"
SERVICE="${SERVICE:-realestate-service}"
NAMESPACE="${NAMESPACE:-emtaf}"
SITE_DIR="realestate-site"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
command -v node >/dev/null || { echo "node is required" >&2; exit 1; }

kubectl -n "$NAMESPACE" port-forward "svc/$SERVICE" "$API_PORT:80" >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true' EXIT
for _ in $(seq 1 120); do
  (echo >/dev/tcp/127.0.0.1/"$API_PORT") >/dev/null 2>&1 && break
  sleep 0.5
done
export API_BASE="http://localhost:$API_PORT" PORT="$SITE_PORT"
echo "[EMTAF] realestate-site -> http://localhost:$SITE_PORT (API $SERVICE via localhost:$API_PORT)"
echo "[EMTAF] Mint a token, then paste it into the site Connect box:"
echo '  export JWT_SECRET="$(kubectl -n emtaf get secret emtaf-platform-secrets -o jsonpath="{.data.JWT_SECRET}" | base64 -d)"'
echo '  npm run token --prefix realestate-site   # realestate.admin@demo.local / demo-realestate'
exec node "$ROOT_DIR/$SITE_DIR/server.mjs"
