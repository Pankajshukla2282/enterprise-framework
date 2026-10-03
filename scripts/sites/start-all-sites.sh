#!/usr/bin/env bash
# Starts every EMTAF website locally: one port-forward per backend service,
# then all eight site servers. Ctrl+C stops everything.
set -euo pipefail
NAMESPACE="${NAMESPACE:-emtaf}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
command -v node >/dev/null || { echo "node is required" >&2; exit 1; }

PIDS=""
cleanup() { kill $PIDS 2>/dev/null || true; }
trap cleanup EXIT

kubectl -n "$NAMESPACE" port-forward svc/hospital-service 8081:80 >/dev/null 2>&1 &
PIDS="$PIDS $!"
kubectl -n "$NAMESPACE" port-forward svc/school-service 8082:80 >/dev/null 2>&1 &
PIDS="$PIDS $!"
kubectl -n "$NAMESPACE" port-forward svc/college-service 8083:80 >/dev/null 2>&1 &
PIDS="$PIDS $!"
kubectl -n "$NAMESPACE" port-forward svc/hotel-service 8084:80 >/dev/null 2>&1 &
PIDS="$PIDS $!"
kubectl -n "$NAMESPACE" port-forward svc/realestate-service 8085:80 >/dev/null 2>&1 &
PIDS="$PIDS $!"

start_site() { # dir sitePort apiPort
  for _ in $(seq 1 120); do
    (echo >/dev/tcp/127.0.0.1/"$3") >/dev/null 2>&1 && break
    sleep 0.5
  done
  API_BASE="http://localhost:$3" PORT="$2" node "$ROOT_DIR/$1/server.mjs" &
  PIDS="$PIDS $!"
  echo "[EMTAF] $1 -> http://localhost:$2"
}

start_site hospital-site 3001 8081
start_site school-site 3003 8082
start_site college-site 3004 8083
start_site hotel-site 3005 8084
start_site realestate-site 3002 8085
start_site skin-clinic-site 3006 8081
start_site eecp-clinic-site 3007 8081
start_site physiotherapy-site 3008 8081

echo "[EMTAF] All sites running. Mint tokens with JWT_SECRET from emtaf-platform-secrets, then Connect in each site. Ctrl+C stops."
wait
