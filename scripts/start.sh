#!/usr/bin/env bash
set -euo pipefail
ENVIRONMENT=dev IMAGE_MODE=local REGISTRY='' TAG=dev NAMESPACE=emtaf
while [[ $# -gt 0 ]]; do case "$1" in --environment) ENVIRONMENT="$2"; shift 2;; --image-mode) IMAGE_MODE="$2"; shift 2;; --registry) REGISTRY="$2"; shift 2;; --tag) TAG="$2"; shift 2;; --namespace) NAMESPACE="$2"; shift 2;; *) ENVIRONMENT="$1"; shift;; esac; done
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"; command -v kubectl >/dev/null || { echo 'kubectl is required'; exit 1; }
if [[ "$IMAGE_MODE" == cloud ]]; then [[ -n "$REGISTRY" ]] || { echo '--registry required in cloud mode'; exit 1; }; GEN="$ROOT/infra/kubernetes/overlays/.generated/$ENVIRONMENT"; mkdir -p "$GEN"; sed -e "s#__EMTAF_REGISTRY__#${REGISTRY%/}#g" -e "s#__EMTAF_TAG__#$TAG#g" -e "s#- ../../base#- ../../$ENVIRONMENT#g" infra/kubernetes/overlays/cloud/kustomization.template.yaml > "$GEN/kustomization.yaml"; APPLY="$GEN"; else APPLY="$ROOT/infra/kubernetes/overlays/$ENVIRONMENT"; fi
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl -n "$NAMESPACE" delete job emtaf-migrations --ignore-not-found=true >/dev/null 2>&1 || true
kubectl apply -k "$APPLY"
for d in postgres redis redpanda; do kubectl -n "$NAMESPACE" rollout status "deployment/$d" --timeout=240s; done
kubectl -n "$NAMESPACE" wait --for=condition=complete job/emtaf-migrations --timeout=300s
for s in tenant hospital school college hotel realestate; do n="emtaf-$s-service"; if kubectl -n "$NAMESPACE" get deployment "$n" --ignore-not-found -o name >/dev/null; then kubectl -n "$NAMESPACE" rollout status "deployment/$n" --timeout=180s; fi; done
if kubectl -n "$NAMESPACE" get deployment emtaf-demo-wireframe --ignore-not-found -o name >/dev/null; then kubectl -n "$NAMESPACE" rollout status deployment/emtaf-demo-wireframe --timeout=180s; fi
echo '[EMTAF] Started successfully.'
