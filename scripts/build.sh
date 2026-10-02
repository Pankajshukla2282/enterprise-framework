#!/usr/bin/env bash
set -euo pipefail
MODE=local REGISTRY='' TAG=dev TARGET=all PUSH=false LOAD=false
while [[ $# -gt 0 ]]; do case "$1" in
  --mode) MODE="$2"; shift 2;; --registry) REGISTRY="$2"; shift 2;; --tag) TAG="$2"; shift 2;; --target) TARGET="$2"; shift 2;; --push) PUSH=true; shift;; --load) LOAD=true; shift;; *) echo "Unknown option: $1"; exit 2;; esac; done
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
command -v docker >/dev/null || { echo 'Docker is required.'; exit 1; }
if [[ "$TARGET" == all ]]; then targets=(tenant hospital school college hotel realestate demo migrations); else targets=("$TARGET"); fi
declare -A map=( [tenant]=services/tenant-service/Dockerfile [hospital]=domains/hospital-service/Dockerfile [school]=domains/school-service/Dockerfile [college]=domains/college-service/Dockerfile [hotel]=domains/hotel-service/Dockerfile [realestate]=domains/realestate-service/Dockerfile [demo]=demo-wireframe/Dockerfile [migrations]=infra/migrations/Dockerfile )
declare -A repos=( [tenant]=emtaf-tenant-service [hospital]=emtaf-hospital-service [school]=emtaf-school-service [college]=emtaf-college-service [hotel]=emtaf-hotel-service [realestate]=emtaf-realestate-service [demo]=emtaf-demo-wireframe [migrations]=emtaf-migrations )
for name in "${targets[@]}"; do repo="${repos[$name]}"; if [[ "$MODE" == cloud ]]; then [[ -n "$REGISTRY" ]] || { echo '--registry is required in cloud mode'; exit 1; }; image="$REGISTRY/$repo:$TAG"; else image="$repo:$TAG"; fi; echo "[EMTAF] Building $image"; docker build -f "${map[$name]}" -t "$image" .; if $LOAD && [[ "$MODE" == local ]]; then if command -v kind >/dev/null; then kind load docker-image "$image"; elif command -v minikube >/dev/null; then minikube image load "$image"; fi; fi; if $PUSH; then [[ "$MODE" == cloud ]] || { echo '--push requires --mode cloud'; exit 1; }; docker push "$image"; fi; done
