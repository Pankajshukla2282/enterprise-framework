#!/usr/bin/env bash
set -euo pipefail
registry="${1:?registry required}"
tag="${2:?tag required}"
command -v cosign >/dev/null || { echo 'cosign is required' >&2; exit 1; }
for n in tenant-service hospital-service school-service college-service hotel-service realestate-service migrations; do
  cosign verify --certificate-identity-regexp 'https://github.com/.*/.github/workflows/.*' --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' "$registry/emtaf-$n:$tag" >/dev/null
done
echo 'All release images have valid keyless signatures.'
