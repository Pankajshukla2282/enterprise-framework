#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--purge" ]]; then kubectl -n emtaf delete deployment emtaf-tenant-service --ignore-not-found; else kubectl -n emtaf scale deployment/emtaf-tenant-service --replicas=0; fi
