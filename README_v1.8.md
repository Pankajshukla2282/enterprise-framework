# EMTAF SaaS v1.8 — Windows + Linux Operations

EMTAF now provides equivalent Kubernetes operations for Linux/macOS and Windows. The platform remains Kubernetes-only; Docker Compose is intentionally not used.

## Windows

- PowerShell 5.1+ / PowerShell 7 scripts in `scripts/*.ps1`
- CMD wrappers in `scripts/windows/*.cmd`
- Optional prerequisite installer/check using `winget`
- `scripts/windows/README.md`

```powershell
.\scripts\install-windows.ps1
.\scripts\start.ps1 -Environment dev
.\scripts\seed.ps1 -Environment dev
.\scripts\status.ps1
.\scripts\stop.ps1 -Environment dev
```

## Linux/macOS

Existing Bash scripts remain available:

```bash
./scripts/start.sh dev
./scripts/seed.sh dev
./scripts/status.sh
./scripts/stop.sh dev
```

Equivalent wrappers are under `scripts/linux/`.

## Kubernetes runtime

The scripts assume a Kubernetes cluster and the standard CLIs `kubectl` and `helm`. For Windows local development, Docker Desktop Kubernetes or Rancher Desktop Kubernetes can be used. Docker is only needed when building images locally.

## Idempotency

- Start uses `kubectl apply` and recreates only the migration Job.
- Stop accepts `--purge-data` / `-PurgeData` for explicit destructive teardown.
- Seed uses deterministic business keys and PostgreSQL upserts.
- Re-running start/seed does not create duplicate demo tenants or domain records.

## Image repository strategy

EMTAF supports registry-free local Kubernetes development and configurable cloud OCI registries. See `docs/IMAGE-REPOSITORY-v1.8.md`. Local mode builds `emtaf-*:<tag>` images directly into the Docker engine and uses `IfNotPresent`; cloud mode uses `-Registry` and an explicit push/login step. No registry login is required for local development.
