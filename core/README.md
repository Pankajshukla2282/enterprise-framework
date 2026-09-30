# EMTAF Core Framework

The shared `@emtaf/core` package supplies cross-domain platform contracts and runtime helpers: authentication context, tenant membership authorization, RBAC/permissions, tenant-aware PostgreSQL access, Redis integration, event-bus integration and audit foundations.

## Contract

Domain services depend on the core; the core must not import domain application code. Tenant identity is resolved from authenticated context and active membership, not from arbitrary client role claims.

## Build

Windows: `core\scripts\build.ps1`

Linux/macOS: `core/scripts/build.sh`

## Documents

- `DEPLOYMENT.md` — package/build and platform integration
- `RUNBOOK.md` — operational guidance
- `scripts/` — core package checks
