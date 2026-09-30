# EMTAF SaaS v1.10.0 — Production Hardening Release

## Highlights
- Tenant isolation and RBAC are strengthened and testable.
- Idempotency is crash-recoverable and bound to tenant/user/request hash.
- Domain writes create transactional outbox records through PostgreSQL triggers.
- Outbox workers use leases, retries and graceful shutdown.
- Event consumers can deduplicate with `consumeOnce()`.
- OpenTelemetry tracing, request IDs and Prometheus metrics are standardized.
- HTTP security middleware adds CORS allow-listing, rate limiting and security headers.
- CI builds all services, scans images, produces SBOM/provenance and signs tagged release images with Cosign.
- PostgreSQL backup/restore validation is automated in CI and available on Windows/Linux.
- Staging/production Kubernetes overlays use external managed platform dependencies and external secrets.
- Dedicated sandbox remains available for staff training and demo data.

## Production deployment requirement
Do not deploy the raw `prod` overlay directly. Use the cloud deployment script with:
- registry;
- immutable release tag;
- managed platform CIDR;
- configured External Secrets `ClusterSecretStore`;
- external PostgreSQL/Redis/Event Bus endpoints;
- OTLP endpoint.

The script refuses unresolved placeholders.

## Validation performed in this build environment
- 26 repository tests: 24 passed, 2 skipped because no PostgreSQL test server is available here.
- Kubernetes YAML: 52 files parsed successfully.
- TypeScript syntax checks: no syntax-level errors detected; full type/build verification requires installed npm dependencies.
- A full `npm install` could not complete in this environment, so no claim is made for a live Kubernetes deployment or full dependency-resolved compilation here.
