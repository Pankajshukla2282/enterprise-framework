# Tenant Service Runbook

## Health

`GET /health/live` and `GET /health/ready`.

## Operations

```bash
kubectl -n emtaf rollout status deployment/emtaf-tenant-service --timeout=180s
kubectl -n emtaf logs deployment/emtaf-tenant-service --tail=200
```

## Security

Membership changes are security-sensitive. Verify the acting user's authorization and target tenant before modifying roles. Do not edit tenant memberships directly in production SQL.
