# EMTAF Kubernetes Infrastructure

Kubernetes is the only orchestration target in this implementation. There is intentionally no docker-compose file.

## Deploy
1. Build/push each domain image independently:
   - `docker build -f domains/hospital-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-hospital-service:dev .`
   - Repeat for school, college and hotel.
2. Create a real secret using External Secrets Operator for staging/prod. Do not commit credentials.
3. `kubectl apply -k infra/kubernetes/overlays/dev`
4. Apply migrations through your CI/CD migration Job before enabling traffic.
5. `helm upgrade --install emtaf infra/helm/emtaf -n emtaf --create-namespace -f infra/helm/emtaf/values.yaml`

## Multi-tenancy
Every business table has `tenant_id`. Every authenticated request resolves `{userId, tenantId, roles}` from the JWT. Queries must always include tenant_id. The domain APIs reject unauthenticated requests and enforce role sets per command.

For production, replace the sample JWT validation with the platform Identity service/JWKS and make tenant membership an authorization lookup or signed entitlement.

## Image repository strategy

EMTAF supports registry-free local Kubernetes development and configurable cloud OCI registries. See `docs/IMAGE-REPOSITORY-v1.8.md`. Local mode builds `emtaf-*:<tag>` images directly into the Docker engine and uses `IfNotPresent`; cloud mode uses `-Registry` and an explicit push/login step. No registry login is required for local development.
