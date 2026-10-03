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


## Domain Web Applications

See `docs/DOMAIN_WEBSITES.md` for the five independently runnable EMTAF domain web applications: hospital, school, college, hotel and real estate.


## Specialty Clinic Web Applications (v1.11.1)

The hospital platform now supports dedicated tenant-scoped specialty workflows:
- `skin-clinic-site` — Skin & Cosmetics, port 3006
- `eecp-clinic-site` — Cardiac EECP Therapy, port 3007
- `physiotherapy-site` — Physiotherapy, port 3008

These sites share the hospital patient registry and `hospital-service` APIs while remaining independently buildable and deployable.

### Build-site fix

`./scripts/build.ps1 -Mode local -Target all` now uses each `*-site` directory as its Docker build context. This prevents `COPY public` / `COPY server.mjs` failures when Docker Desktop builds the site images.

## Specialty Clinic Products

EMTAF now provides three independently deployable specialty products backed by the multi-tenant hospital clinical platform:

- Skin & Cosmetics — `skin-clinic-site` — port 3006
- Cardiac EECP Therapy — `eecp-clinic-site` — port 3007
- Physiotherapy & Rehabilitation — `physiotherapy-site` — port 3008

Each product has its own dashboard/navigation, specialty RBAC roles, clinical workflow, appointment lifecycle, billing packages/invoices, reports and patient portal. The specialty data remains tenant-scoped and protected by the EMTAF authorization/RLS model.

See `RELEASE_NOTES_v1.11.2_BUILD_AND_SPECIALTY_PRODUCTS.md` for the implementation and validation details.
