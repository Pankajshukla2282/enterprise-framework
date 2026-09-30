# School Service Runbook

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
kubectl -n emtaf logs deployment/school-service --tail=200
kubectl -n emtaf describe deployment school-service
```

## Rollout / rollback

```bash
kubectl -n emtaf rollout restart deployment/school-service
kubectl -n emtaf rollout status deployment/school-service --timeout=180s
kubectl -n emtaf rollout history deployment/school-service
kubectl -n emtaf rollout undo deployment/school-service
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
