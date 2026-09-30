# Hospital Service Runbook

## Health

```text
GET /health/live
GET /health/ready
GET /metrics
```

## Status

Windows:
```powershell
.\scripts\status.ps1
```

Linux/macOS:
```bash
./scripts/status.sh
```

## Logs

```bash
kubectl -n emtaf logs deployment/hospital-service --tail=200
kubectl -n emtaf describe deployment hospital-service
```

## Rollout / rollback

```bash
kubectl -n emtaf rollout restart deployment/hospital-service
kubectl -n emtaf rollout status deployment/hospital-service --timeout=180s
kubectl -n emtaf rollout history deployment/hospital-service
kubectl -n emtaf rollout undo deployment/hospital-service
```

## Tenant/RBAC incident checks

1. Confirm the JWT identifies the expected user.
2. Confirm the requested tenant exists and the user has an active membership.
3. Confirm the effective role grants the required permission.
4. Confirm the request is using the intended tenant context.
5. Check PostgreSQL/RLS logs before bypassing application authorization.

## Data safety

Do not disable RLS or manually edit production tenant data to work around an authorization issue. Use the tenant-aware service/API workflow and audited administrative operations.

## Sample data

The root seed is deterministic and safe to rerun. Service-local `seed` scripts delegate to the shared seed workflow so the database remains consistent across domain relationships.

## Idempotent transaction recovery

If a client reports an uncertain result for patient creation, admission allocation or payment, do not immediately retry without the original `Idempotency-Key`. First inspect the response/audit reference. A retry with the same key is safe; a new key can create a new transaction.

## Outbox recovery

Check `platform_outbox` for unpublished events and inspect `attempts`, `last_error` and `next_attempt_at`. The outbox worker retries failed publications. Do not manually duplicate events in the Event Bus.
