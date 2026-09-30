# EMTAF Hospital Service

This service owns the clinical operations domain and is independently buildable and deployable. It consumes the shared `@emtaf/core` framework and is tenant-scoped.

## Domain scope

See the service source and migration files for the current module inventory. Every persisted business record is associated with a `tenant_id`; authorization is resolved from the authenticated user's membership in the requested tenant.

## Roles

superadmin, admin, doctor, nurse, accountant, receptionist, patient

## Local development

From the repository root, install dependencies once and build this workspace. The service can run against the local Kubernetes platform using the root operations scripts or its service-specific scripts.

Windows:
```powershell
.\scripts\build.ps1 -Target hospital -Mode local
.\scripts\deploy.ps1 -Environment dev -ImageMode local
.\scripts\status.ps1
```

Linux/macOS:
```bash
./scripts/build.sh --target hospital --mode local
./scripts/deploy.sh dev
./scripts/status.sh
```

## Kubernetes

The service has its own Helm chart under `helm/`. It is also included in the platform Kustomize overlays.

## Documents

- `DEPLOYMENT.md` — build, image and Kubernetes deployment steps
- `RUNBOOK.md` — operational checks, rollback and troubleshooting
- `docs/RBAC.md` — service permission notes where present

## Production-hardening behavior

The following critical writes require an `Idempotency-Key` header and are backed by the transactional outbox:

- `POST /api/v1/hospital/patients`
- `POST /api/v1/hospital/admissions/allocate`
- `POST /api/v1/hospital/billing/:id/payments`

Reusing the same key with the same request returns the stored result. Reusing it with a different request is rejected. Domain state and the corresponding outbox event are committed atomically.
