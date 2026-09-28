# EMTAF v1.8.1 — Image Repository / Offline Development Update

This update makes container image handling independent of a preconfigured registry login.

## Local development

- Builds `emtaf-*` images directly into the local Docker engine.
- Kubernetes uses `IfNotPresent`.
- Docker Desktop Kubernetes can consume the local images directly.
- kind/minikube image loading is supported by the build script.
- Images can be exported/imported as Docker tar archives for disconnected machines.

## Cloud

- Any OCI-compatible registry can be supplied at deployment time.
- Registry authentication is explicit; EMTAF never assumes the developer is logged in.
- Application images are pushed only when `-Push` is supplied.
- PostgreSQL, Redis and Redpanda can be mirrored to the private registry for clusters without Internet egress.

## Commands

Windows:

```powershell
.\scripts\build.ps1 -Mode local -Target all
.\scripts\start.ps1 -Environment dev -ImageMode local
.\scripts\images.ps1 -Action save -IncludePlatform
```

Cloud:

```powershell
.\scripts\registry.ps1 -Action login -Registry <registry>/<org>
.\scripts\build.ps1 -Mode cloud -Registry <registry>/<org> -Tag 1.8.1 -Push
.\scripts\registry.ps1 -Action mirror-platform -Registry <registry>/<org>
.\scripts\start.ps1 -Environment prod -ImageMode cloud -Registry <registry>/<org> -Tag 1.8.1
```
