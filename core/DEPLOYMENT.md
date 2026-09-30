# EMTAF Core Deployment

The core package is a library consumed by domain/platform services; it is not deployed as a standalone Kubernetes Deployment. Build it as part of the service image or workspace.

## Build

```powershell
.\core\scripts\build.ps1
```

```bash
./core/scripts/build.sh
```

## Release

Publish the resulting workspace package through the normal repository/package pipeline. Domain image builds include the compiled core dependency.

## Compatibility

Keep the core API backward compatible across independently deployed domains. Coordinate breaking changes with a versioned package release and update all domain workspaces before production rollout.
