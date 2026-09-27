# EMTAF v1.0 deployment

## 1. Build independently

```bash
npm install
npm run build:tenant
npm run build:hospital
npm run build:school
npm run build:college
npm run build:hotel
```

Build each container independently from the repository root:

```bash
docker build -f domains/hospital-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-hospital-service:1.0.0 .
docker build -f domains/school-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-school-service:1.0.0 .
docker build -f domains/college-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-college-service:1.0.0 .
docker build -f domains/hotel-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-hotel-service:1.0.0 .
docker build -f services/tenant-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-tenant-service:1.0.0 .
```

No Docker Compose is required or included.

## 2. Kubernetes

Dev/staging/prod are Kustomize overlays:

```bash
kubectl apply -k infra/kubernetes/overlays/dev
kubectl apply -k infra/kubernetes/overlays/staging
kubectl apply -k infra/kubernetes/overlays/prod
```

For production, install External Secrets Operator and configure an AWS ClusterSecretStore. The ExternalSecret in `infra/secrets/external-secrets.yaml` materializes `emtaf-platform-secrets` from AWS Secrets Manager.

## 3. Helm

Each domain has its own chart under `domains/<domain>-service/helm`. Deploy one independently, for example:

```bash
helm upgrade --install emtaf-hospital domains/hospital-service/helm -n emtaf --create-namespace
```

## 4. Tenant/RBAC

`tenant-service` manages tenants and tenant memberships. Domain services derive effective roles from `tenant_memberships`. Never trust roles supplied by a browser/client. Every domain row has `tenant_id`, application queries execute inside `Database.withTenant()`, and PostgreSQL RLS provides a second boundary.
