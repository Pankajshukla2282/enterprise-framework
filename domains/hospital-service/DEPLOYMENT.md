# Hospital Service Deployment

## Prerequisites

- Node.js >= 22
- npm
- Docker for local image builds
- `kubectl`
- `helm` for standalone chart deployment
- A Kubernetes cluster

## Local image deployment

Windows PowerShell:
```powershell
.\scripts\build.ps1 -Mode local
.\scripts\deploy.ps1 -Environment dev -ImageMode local
```

Linux/macOS:
```bash
./scripts/build.sh --mode local
./scripts/deploy.sh dev
```

No registry login is required for local Docker Desktop Kubernetes when the image is available in the local engine. For kind/minikube, load the image into the cluster as required by the cluster runtime.

## Cloud/private registry

Build and push through the root image workflow, then deploy with the generated cloud Kustomize overlay or pass the image repository/tag to the Helm chart. Registry authentication is explicit; EMTAF does not assume a login.

## Standalone Helm

Use the service-local deploy script for an idempotent release:

Windows: `scripts\deploy.ps1`

Linux/macOS: `scripts/deploy.sh dev`

Equivalent direct command:

```bash
helm upgrade --install emtaf-hospital ./helm -n emtaf --create-namespace --set image.repository=emtaf-hospital-service --set image.tag=dev
```

## Full platform deployment

The platform migration Job must complete before the service is considered ready:

```bash
kubectl -n emtaf wait --for=condition=complete job/emtaf-migrations --timeout=300s
kubectl -n emtaf rollout status deployment/hospital-service --timeout=180s
```

## Configuration

The service consumes the shared platform configuration for database, Redis, event bus and JWT settings. Production secrets should come from External Secrets or an equivalent secret manager.
