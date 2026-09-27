# EMTAF SaaS v1.2–v1.5 consolidated release

## v1.2 — Transactional domain workflows
- Atomic Hospital admission + bed allocation transaction.
- PostgreSQL row locking/advisory lock prevents duplicate allocation races.
- Complete Hospital migration aligned with application tables.
- School CRUD workflow corrected and expanded.

## v1.3 — API contracts and authorization hardening
- OpenAPI contracts for Hospital and School.
- Tenant-scoped RBAC remains enforced through core authorization.
- School attendance permissions added.
- Patient/self-service permission model retained in core.

## v1.4 — Operational resilience
- Health/readiness/liveness endpoints.
- Prometheus metrics.
- Kubernetes resource limits, probes, HPA and PDB support.
- Independent domain container build pipelines.

## v1.5 — Two working domain services
Hospital and School are now first-class independently buildable/deployable services using the same EMTAF core framework.

Both services require a valid JWT and an active tenant membership. Production deployment requires PostgreSQL, Redis, Event Bus and secrets to be provisioned by Kubernetes/External Secrets.
