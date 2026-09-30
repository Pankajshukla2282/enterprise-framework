# EMTAF SaaS Platform

EMTAF is a Kubernetes-first, multi-tenant SaaS platform with a shared core and independently deployable domain services. Docker Compose is not used.

## Domain portfolio

- Hospital — clinical and hospital operations
- School — students, teachers, classes, enrollments and attendance
- College — students, faculty, departments, courses, enrollments, attendance, fees and exams
- Hotel — guests, rooms, bookings, check-in/out, payments and housekeeping
- Real Estate — properties, units, listings, leads, viewings, offers, leases and payments

## Shared core

The core provides authentication context, tenant membership, tenant-scoped RBAC, PostgreSQL tenant context/RLS, Redis primitives, event-bus integration, audit foundations and operational contracts. The tenant service provides tenant and membership administration.

## Deployment model

Kubernetes is the runtime. Kustomize provides `dev`, `staging`, and `prod` overlays; each domain also has an independent Helm chart. Local development can use locally built images without a registry login. Cloud/private OCI registries are supported explicitly.

## Platform operations

Use the root scripts for full-platform operations:

### Windows
```powershell
.\scripts\install-windows.ps1
.\scripts\build.ps1 -Mode local -Target all
.\scripts\start.ps1 -Environment dev -ImageMode local
.\scripts\seed.ps1 -Environment dev
.\scripts\status.ps1
.\scripts\stop.ps1 -Environment dev
```

### Linux/macOS
```bash
./scripts/build.sh --mode local --target all
./scripts/start.sh dev
./scripts/seed.sh dev
./scripts/status.sh
./scripts/stop.sh dev
```

For an individual service, use that service's own `README.md`, `DEPLOYMENT.md`, `RUNBOOK.md`, and `scripts/` directory.

## Documentation layout

```text
README.md                         # platform overview
CHANGELOG.md                      # consolidated release history
core/README.md                    # core framework
core/DEPLOYMENT.md                # core deployment
core/RUNBOOK.md                   # core operations
core/scripts/                      # core-local operations
services/tenant-service/           # tenant platform service
domains/<service>/README.md       # domain overview
domains/<service>/DEPLOYMENT.md   # domain deployment
domains/<service>/RUNBOOK.md      # domain operations
domains/<service>/scripts/        # domain operations
docs/                             # cross-cutting architecture/API/security docs
demo-wireframe/README.md          # demo UI
```

Historical root README and release-note files have been consolidated into this README and `CHANGELOG.md` to keep the repository uncluttered.

## Production hardening v1.9.1

See `docs/PRODUCTION-HARDENING-v1.9.1.md`. Critical Hospital writes now support transactional idempotency and outbox events; tenant tables use FORCE RLS; OpenTelemetry tracing, CI security gates, backup/restore verification and an isolated training sandbox are included.

## v1.10 production hardening
See `docs/PRODUCTION-READY-v1.10.md` for the controlled-production acceptance gate. Production/staging use external managed PostgreSQL/Redis/Event Bus and external secrets; local/dev/sandbox can continue to use the in-cluster platform infrastructure.
