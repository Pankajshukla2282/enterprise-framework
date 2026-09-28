# EMTAF SaaS v1.7 — Kubernetes Operations + Demo Wireframe

## Added

- Idempotent Kubernetes start script: `scripts/start.sh [dev|staging|prod]`
- Idempotent teardown script: `scripts/stop.sh [dev|staging|prod] [--purge-data]`
- Status script: `scripts/status.sh`
- Idempotent sample-data seed script: `scripts/seed.sh [dev|staging|prod]`
- Deterministic seed dataset for Hospital, School, College, Hotel and Real Estate
- Development secret overlay with a non-placeholder PostgreSQL password for the Kubernetes demo environment
- Independently deployable `demo-wireframe` nginx deployment
- Responsive browser wireframe with tenant switching, domain navigation, RBAC role switching, dashboards, tables and simulated workflows
- Kubernetes base + environment image wiring for the demo wireframe

## Demo

Run the wireframe directly with:

```bash
cd demo-wireframe
python3 -m http.server 8080
```

Or build/publish `demo-wireframe/Dockerfile` and deploy the Kubernetes manifest through the environment overlay.

## Idempotency

Start safely reapplies the selected Kustomize overlay and recreates the migration Job. Seed operations use business-key upserts and `ON CONFLICT` handling. Stop is safe to repeat; `--purge-data` is the explicit destructive mode.
