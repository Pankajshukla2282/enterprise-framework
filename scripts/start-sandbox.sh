#!/usr/bin/env bash
set -euo pipefail
kubectl apply -k infra/kubernetes/overlays/sandbox
kubectl rollout status deployment/hospital-service -n emtaf-training --timeout=180s
kubectl rollout status deployment/demo-wireframe -n emtaf-training --timeout=180s
if [[ "${1:-}" == "--seed" ]]; then "$PWD/scripts/seed.sh" sandbox; fi
