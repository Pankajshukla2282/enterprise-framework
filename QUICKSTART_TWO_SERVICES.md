# EMTAF v1.2–v1.5 — Two Service Quickstart

This release deliberately does not use Docker Compose.

## Build images

```bash
docker build -f domains/hospital-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-hospital-service:1.5.0 .
docker build -f domains/school-service/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-school-service:1.5.0 .
```

Push them to the registry configured by your Kubernetes manifests.

## Deploy core infrastructure and both domains

```bash
kubectl apply -k infra/kubernetes/overlays/dev
```

The migration Job must complete before application traffic is enabled:

```bash
kubectl -n emtaf get jobs
kubectl -n emtaf get pods
```

## Independently deploy one domain

```bash
helm upgrade --install emtaf-hospital domains/hospital-service/helm -n emtaf --create-namespace
helm upgrade --install emtaf-school domains/school-service/helm -n emtaf --create-namespace
```

## Required runtime settings

- `DATABASE_URL`
- `REDIS_URL`
- `KAFKA_BROKERS`
- `JWT_SECRET`

Production secrets should come from External Secrets/AWS Secrets Manager rather than checked-in Kubernetes Secret manifests.

## Service health

Hospital: `GET /health/live`, `GET /health/ready`, `GET /metrics`

School: `GET /health/live`, `GET /health/ready`, `GET /metrics`

Both services require an authenticated JWT for domain APIs and verify active tenant membership through the EMTAF core framework.
