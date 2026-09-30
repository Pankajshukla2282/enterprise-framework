#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
"$ROOT/scripts/status.sh"
kubectl -n emtaf get deployment hospital-service -o wide
kubectl -n emtaf get pods -l app=hospital-service -o wide
