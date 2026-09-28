# EMTAF v1.8 Image Repository Strategy

EMTAF supports two image distribution modes. The development machine does **not** need to be logged into a container registry.

## 1. Local/offline development — default

Images are built into the local Docker engine with names such as:

- `emtaf-hospital-service:dev`
- `emtaf-school-service:dev`
- `emtaf-college-service:dev`
- `emtaf-hotel-service:dev`
- `emtaf-realestate-service:dev`
- `emtaf-tenant-service:dev`
- `emtaf-demo-wireframe:dev`
- `emtaf-migrations:dev`

Kubernetes uses `imagePullPolicy: IfNotPresent`.

For Docker Desktop Kubernetes, no registry login is required and Kubernetes can use images already present in Docker Desktop's local image store.

For kind:

```powershell
.\scripts\build.ps1 -Mode local -Load
```

For minikube:

```powershell
.\scripts\build.ps1 -Mode local -Load
```

The build script detects kind/minikube and loads the images where appropriate.

### Important offline requirement

A completely disconnected machine must already have the required base images cached locally, including Node, nginx and PostgreSQL/Redis/Redpanda images. Docker cannot build an image from a base image that is not present locally.

## 2. Cloud registry mode

Any OCI-compatible registry can be used:

- GitHub Container Registry
- Amazon ECR
- Azure Container Registry
- Google Artifact Registry
- Harbor
- another private OCI registry

Set:

```text
EMTAF_REGISTRY=<registry>/<organization-or-project>
EMTAF_IMAGE_TAG=1.8.0
```

Then login using the registry's normal Docker authentication mechanism:

```powershell
.\scripts\registry.ps1 -Action login -Registry <registry>
```

Build and push:

```powershell
.\scripts\build.ps1 -Mode cloud -Registry <registry>/<org> -Tag 1.8.0 -Push
```

Linux/macOS:

```bash
./scripts/build.sh --mode cloud --registry <registry>/<org> --tag 1.8.0 --push
```

Deploy from the registry:

```powershell
.\scripts\start.ps1 -Environment prod -ImageMode cloud -Registry <registry>/<org> -Tag 1.8.0
```

## 3. Kubernetes image resolution

The base Kubernetes manifests use stable logical image names. The environment overlay or generated cloud overlay resolves those names to either local images or a cloud registry.

This prevents registry-specific URLs from being embedded in application manifests.

## 4. No registry login for local development

The intended Windows developer workflow is:

```powershell
.\scripts\build.ps1 -Mode local -Target all
.\scripts\start.ps1 -Environment dev -ImageMode local
.\scripts\seed.ps1 -Environment dev
```

## 5. Cloud deployment is explicit

Cloud mode never silently pushes images. `-Push` is required. This prevents accidental publication of local builds.

## 6. Moving images to an air-gapped Windows/Linux machine

On a connected build machine:

```powershell
.\scripts\images.ps1 -Action save -IncludePlatform
```

Copy `artifacts/images` to the offline machine, then:

```powershell
.\scripts\images.ps1 -Action load
```

The equivalent Linux/macOS command is:

```bash
./scripts/images.sh --action save --include-platform
./scripts/images.sh --action load
```

This is the recommended registry-free transfer mechanism for a truly offline development environment.

## 7. Private cloud registry without public image dependencies

If the target Kubernetes cluster has no Internet egress, mirror the runtime platform images into the same private registry from a connected machine:

```powershell
.\scripts\registry.ps1 -Action mirror-platform -Registry <registry>/<org>
```

or:

```bash
./scripts/registry.sh --action mirror-platform --registry <registry>/<org>
```

The cloud Kustomize overlay then resolves PostgreSQL, Redis and Redpanda to the private registry as well as the EMTAF application images.
