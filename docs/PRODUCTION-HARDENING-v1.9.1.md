# EMTAF v1.9.1 Production Hardening

## Implemented
- PostgreSQL FORCE ROW LEVEL SECURITY for domain tables.
- Tenant-isolation integration tests.
- RBAC/security tests.
- Transactional idempotency records keyed by tenant + Idempotency-Key.
- Transactional outbox table and publisher worker.
- Critical Hospital workflows migrated to idempotent + outbox-backed writes: patient creation, admission/bed allocation, billing payment.
- W3C trace/request identifiers and OpenTelemetry auto-instrumentation.
- Kubernetes OpenTelemetry collector.
- CI security gates: dependency audit, build, security tests, integration tests, Trivy image scanning and Gitleaks.
- PostgreSQL custom-format backup and disposable-database restore verification scripts.
- Dedicated `emtaf-training` Kubernetes sandbox overlay and start/stop scripts.

## Idempotency contract
Critical POST operations require an `Idempotency-Key` header. Reusing a key with a different request body/path is rejected with HTTP 409. Replaying the same request returns the stored response without repeating the business operation.

## Outbox contract
Domain changes and their outbox event are committed in the same PostgreSQL transaction. The outbox worker publishes pending events to the Event Bus and records publication state. Failed events are retried with exponential backoff. Consumers must remain idempotent.

## Observability
Services emit Prometheus metrics and OpenTelemetry traces when `OTEL_ENABLED=true`. `OTEL_EXPORTER_OTLP_ENDPOINT` configures the OTLP HTTP collector endpoint.

## Backups
Windows: `scripts\backup.ps1` and `scripts\restore-verify.ps1`.
Linux: `scripts/backup.sh` and `scripts/restore-verify.sh`.
Use a disposable verification database for restore tests.

## Training sandbox
`kubectl apply -k infra/kubernetes/overlays/sandbox` deploys an isolated `emtaf-training` namespace. Use sample data only.
