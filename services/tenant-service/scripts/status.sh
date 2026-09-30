#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"; "$ROOT/scripts/status.sh"; kubectl -n emtaf get deployment emtaf-tenant-service -o wide
