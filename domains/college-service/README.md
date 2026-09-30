# EMTAF College Service

This service owns the college/academic operations domain and is independently buildable and deployable. It consumes the shared `@emtaf/core` framework and is tenant-scoped.

## Domain scope

See the service source and migration files for the current module inventory. Every persisted business record is associated with a `tenant_id`; authorization is resolved from the authenticated user's membership in the requested tenant.

## Roles

collegeadmin, faculty, staff, student, accountant

## Local development

From the repository root, install dependencies once and build this workspace. The service can run against the local Kubernetes platform using the root operations scripts or its service-specific scripts.

Windows:
```powershell
.\scripts\build.ps1 -Target college -Mode local
.\scripts\deploy.ps1 -Environment dev -ImageMode local
.\scripts\status.ps1
```

Linux/macOS:
```bash
./scripts/build.sh --target college --mode local
./scripts/deploy.sh dev
./scripts/status.sh
```

## Kubernetes

The service has its own Helm chart under `helm/`. It is also included in the platform Kustomize overlays.

## Documents

- `DEPLOYMENT.md` — build, image and Kubernetes deployment steps
- `RUNBOOK.md` — operational checks, rollback and troubleshooting
- `docs/RBAC.md` — service permission notes where present
