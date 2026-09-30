# Tenant Service Deployment

Build from the repository root or use the service-local wrapper scripts.

Windows:
```powershell
.\scripts\build.ps1 -Mode local
.\scripts\deploy.ps1 -Environment dev
```

Linux/macOS:
```bash
./scripts/build.sh --mode local
./scripts/deploy.sh dev
```

The Kubernetes deployment is `emtaf-tenant-service`. It consumes the shared platform configuration and secrets.
