# EMTAF SaaS v1.0 — Kubernetes-first multi-tenant core + independently deployable domains

This release removes Docker Compose entirely. Kubernetes/Kustomize/Helm are the deployment model.

## Architecture
- Shared `@emtaf/core`: JWT parsing, tenant membership authorization, RBAC/permissions, PostgreSQL transaction tenant context, Redis, Kafka-compatible event bus, audit logging.
- `tenant-service`: tenant and tenant-membership administration.
- Independent domain services: hospital, school, college, hotel.
- PostgreSQL tenant_id + RLS defense-in-depth.
- Redis for platform cache/session primitives.
- Redpanda/Kafka-compatible event bus for domain events.
- External Secrets/AWS Secrets Manager integration for production secrets.
- Health probes, HPA, resources, NetworkPolicies, Prometheus metrics and OpenTelemetry/ServiceMonitor manifests.

## Multi-tenant RBAC
A JWT identifies the user and requested tenant. Effective roles are resolved from `tenant_memberships` for that tenant. Client-supplied role claims are not trusted for authorization.

Hospital roles: `superadmin`, `admin`, `doctor`, `nurse`, `accountant`, `receptionist`, `patient`.

The same user can belong to multiple tenants with different roles.

## Independent builds
```bash
npm run build:tenant
npm run build:hospital
npm run build:school
npm run build:college
npm run build:hotel
```

Each service has its own Dockerfile and Helm chart. No Compose files are included.

## Kubernetes
```bash
kubectl apply -k infra/kubernetes/overlays/dev
kubectl apply -k infra/kubernetes/overlays/staging
kubectl apply -k infra/kubernetes/overlays/prod
```

Production should use managed PostgreSQL/Redis/Kafka where appropriate and External Secrets for credentials.

See `DEPLOYMENT.md` for image builds and Helm deployment.

## EMTAF v1.6 domain portfolio

The platform now includes five independently deployable domain services:

- hospital-service — hospital operations and clinical workflows
- school-service — students, teachers, classes, enrollments and attendance
- college-service — students, faculty, departments, courses, enrollments, attendance, fees and exams
- hotel-service — guests, room inventory, bookings, check-in/out, payments and housekeeping
- realestate-service — properties, units, listings, leads, viewings, offers, leases and payments

All domain services consume the shared core framework and use tenant-scoped authentication, RBAC, PostgreSQL RLS, audit and domain events. Kubernetes and Helm artifacts are included for each service; there is no Docker Compose.

## Image repository strategy

EMTAF supports registry-free local Kubernetes development and configurable cloud OCI registries. See `docs/IMAGE-REPOSITORY-v1.8.md`. Local mode builds `emtaf-*:<tag>` images directly into the Docker engine and uses `IfNotPresent`; cloud mode uses `-Registry` and an explicit push/login step. No registry login is required for local development.

## Image repository update

v1.8.1 adds registry-free local image operation plus configurable cloud OCI registry support. See `docs/IMAGE-REPOSITORY-v1.8.md` and `RELEASE_NOTES_v1.8.1_IMAGE_REPOSITORY.md`.
