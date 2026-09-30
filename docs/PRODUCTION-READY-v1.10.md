# EMTAF v1.10 — Controlled Production Readiness

## Scope
This release hardens the EMTAF multi-tenant platform for controlled real-world deployment. It is designed for Kubernetes and supports Windows development plus Linux/cloud operations.

## Security and tenant isolation
- JWT validation supports issuer/audience and rejects weak/default secrets in production.
- Tenant membership is resolved server-side; token tenant and `X-Tenant-Id` cannot disagree.
- PostgreSQL RLS uses `FORCE ROW LEVEL SECURITY` for domain and tenant-sensitive platform tables.
- RBAC remains tenant-scoped.
- HTTP security headers, CORS allow-listing, rate limiting and request/trace correlation are enabled.

## Transaction safety
- Critical Hospital operations use idempotency keys.
- Idempotency keys are bound to tenant + user + request hash.
- In-progress idempotency records have a lease and can recover after a worker/process failure.
- Domain database writes generate outbox records inside the same PostgreSQL transaction through database triggers.
- Outbox workers use claim leases and exponential retry backoff.
- Consumers can use `consumeOnce()` and `platform_consumed_events` for duplicate-event protection.

## Observability
- OpenTelemetry auto-instrumentation is enabled for HTTP/Express/PG and exports OTLP traces.
- Services expose Prometheus metrics.
- `X-Request-Id`, `X-Trace-Id` and W3C `traceparent` are propagated.

## CI/CD security gates
The CI pipeline includes:
1. dependency audit;
2. TypeScript build;
3. security/RBAC tests;
4. PostgreSQL tenant-isolation integration tests;
5. container builds with provenance and SBOM;
6. Trivy HIGH/CRITICAL image scanning;
7. Gitleaks secret scanning;
8. Cosign release-signing gate;
9. backup/restore validation.

Production image promotion should use immutable digests and signed artifacts.

## Backup and disaster recovery
- `scripts/backup.ps1` / `backup.sh` create PostgreSQL custom-format backups and checksums.
- `scripts/dr-verify.ps1` / `dr-verify.sh` restore into a disposable database and execute smoke queries.
- CI performs a backup → restore → data verification cycle.
- Production operations should additionally schedule backups according to the required RPO and test restores at least quarterly.

## Kubernetes production topology
Production/staging should use managed or HA services:
- PostgreSQL
- Redis
- Kafka/Redpanda-compatible Event Bus
- External Secrets Operator + cloud/provider secret store

The single-node PostgreSQL/Redis/Redpanda manifests remain intended for development/sandbox only.

Production overlay requires operator-provided:
- image registry/tag;
- managed-service network CIDR(s);
- external secret store;
- PostgreSQL URL;
- JWT secret;
- Redis URL;
- Event Bus brokers;
- OTLP endpoint as applicable.

The Windows deployment script refuses to apply staging/production manifests while placeholders remain.

## Acceptance gate before real customer data
The repository-level tests are not a substitute for a live environment acceptance test. Before onboarding real tenants:

- run the complete CI pipeline;
- deploy sandbox and execute all workflows;
- run real PostgreSQL RLS tests against the target PostgreSQL version;
- test every RBAC allow/deny path;
- replay idempotent requests concurrently;
- stop/restart the outbox worker and verify eventual publication;
- test duplicate-event consumption;
- restore a production backup to a disposable environment;
- verify alerts, traces, metrics and audit logs;
- validate NetworkPolicies against the real managed-service CIDRs;
- perform a controlled failover/rollback drill;
- obtain security/compliance approval appropriate to the domain.
