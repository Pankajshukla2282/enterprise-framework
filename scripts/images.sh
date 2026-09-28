#!/usr/bin/env bash
set -euo pipefail
ACTION=list DIRECTORY=./artifacts/images TAG=dev INCLUDE_PLATFORM=false
while [[ $# -gt 0 ]]; do case "$1" in --action) ACTION="$2"; shift 2;; --directory) DIRECTORY="$2"; shift 2;; --tag) TAG="$2"; shift 2;; --include-platform) INCLUDE_PLATFORM=true; shift;; *) echo "Unknown option: $1"; exit 2;; esac; done
command -v docker >/dev/null || { echo 'Docker is required'; exit 1; }
images=("emtaf-tenant-service:$TAG" "emtaf-hospital-service:$TAG" "emtaf-school-service:$TAG" "emtaf-college-service:$TAG" "emtaf-hotel-service:$TAG" "emtaf-realestate-service:$TAG" "emtaf-demo-wireframe:$TAG" "emtaf-migrations:$TAG")
if $INCLUDE_PLATFORM; then images+=(postgres:16-alpine redis:7-alpine docker.redpanda.com/redpandadata/redpanda:v24.3.5 node:22-alpine nginx:1.27-alpine); fi
case "$ACTION" in
 list) for i in "${images[@]}"; do docker image inspect "$i" --format '{{.RepoTags}}' 2>/dev/null || true; done;;
 save) mkdir -p "$DIRECTORY"; for i in "${images[@]}"; do docker image inspect "$i" >/dev/null || { echo "Image not found: $i"; exit 1; }; safe="${i//\//_}"; safe="${safe//:/_}"; docker save -o "$DIRECTORY/$safe.tar" "$i"; done;;
 load) shopt -s nullglob; for f in "$DIRECTORY"/*.tar; do docker load -i "$f"; done;;
 *) echo 'Action must be list, save or load'; exit 2;; esac
