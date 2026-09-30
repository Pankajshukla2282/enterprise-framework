# EMTAF Changelog

## v1.9.1 — Production Hardening
- Added FORCE RLS tenant-isolation enforcement.
- Added integration/security tests.
- Added idempotency and transactional outbox support.
- Added outbox worker and Kubernetes deployment.
- Added OpenTelemetry tracing and collector.
- Added CI security gates and image scanning.
- Added backup/restore validation tooling.
- Added isolated training/sandbox Kubernetes overlay.

# EMTAF Consolidated Changelog

## v1.8.1 — Image repository / offline development
- Added registry-free local image builds.
- Added explicit cloud/private OCI registry configuration and authentication.
- Added image save/load workflows for disconnected environments.
- Added private mirroring support for platform images.

## v1.8 — Windows + Linux operations and aligned documentation
- Added PowerShell and CMD workflows for Windows.
- Retained Bash workflows for Linux/macOS.
- Added idempotent start, stop, status, build and seed operations.
- Aligned documentation and API references with the implementation.

## v1.7 — Kubernetes operations and demo wireframe
- Added idempotent Kubernetes start/stop/status/seed operations.
- Added deterministic sample data for all five domains.
- Added responsive multi-tenant demo wireframe.

## v1.6 — Complete domain portfolio + Real Estate
- Expanded College with faculty, departments, courses, enrollments, attendance, fees, exams and results.
- Expanded Hotel with room inventory, bookings, check-in/out, payments and housekeeping.
- Added Real Estate as an independently deployable domain.
- Expanded PostgreSQL migrations/RLS and Kubernetes/Helm artifacts.

## v1.5 — Two working domain services
- Hospital and School became first-class independently buildable/deployable services using the shared core.

## v1.4 — Operational resilience
- Added health/readiness/liveness, Prometheus metrics, resources, probes, HPA/PDB and independent containers.

## v1.3 — API contracts and authorization hardening
- Added Hospital and School OpenAPI contracts and tenant-scoped RBAC hardening.

## v1.2 — Transactional workflows
- Added atomic Hospital admission + bed allocation and corrected School CRUD workflow.

## v1.1 — Hospital reference domain
- Added the broader Hospital clinical/operational module set, tenant isolation, RLS and Hospital RBAC.

## v1.0 — Kubernetes-first core
- Established shared core, tenant service, PostgreSQL, Redis, event bus, RLS, Kubernetes overlays and independently deployable domains.

## v0.7 — Original platform baseline
- Initial platform/domain architecture and Kubernetes direction. See `docs/ARCHITECTURE-v0.7.md` for the retained historical baseline.

## v1.10.0 — Production hardening completion
- Added leased idempotency recovery and same-user protection.
- Added transactional database-triggered outbox and consumer dedupe.
- Added OpenTelemetry resource metadata and safer auth validation.
- Added production/staging external-platform overlays and PDBs.
- Added SBOM/provenance CI gates, Trivy, Gitleaks and Cosign release gate.
- Added backup/restore disaster-recovery verification scripts.
- Added dedicated sandbox/production readiness documentation.

## v1.10.0 — Production hardening completion
- Centralized RBAC permission matrix in `core/src/rbac.ts`.
- Added runtime RBAC matrix tests after build.
- Added tenant/user/request-bound idempotency recovery.
- Added transactional database-triggered outbox, worker leases and consumer dedupe.
- Added OpenTelemetry resource metadata, CORS, rate limiting and safer JWT validation.
- Added external managed-service staging/production overlays and PDBs.
- Added backup/restore CI validation and image signature verification scripts.
- Added SBOM/provenance and Cosign release gates.
- Added controlled-production acceptance documentation.
