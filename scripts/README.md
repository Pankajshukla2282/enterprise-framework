# EMTAF Kubernetes operations

These scripts intentionally use **Kubernetes only**. Docker Compose is not required.

## Start

```bash
./scripts/start.sh dev
```

The script reapplies the selected Kustomize overlay and recreates the migration Job so it can be safely run repeatedly.

## Seed

```bash
./scripts/seed.sh dev
```

The seed SQL uses deterministic business codes/emails and `ON CONFLICT`/upsert logic, so it is safe to run repeatedly.

## Status

```bash
./scripts/status.sh
```

## Stop / teardown

Retain namespace and database data:

```bash
./scripts/stop.sh dev
```

Purge namespace and data:

```bash
./scripts/stop.sh dev --purge-data
```

> Production note: replace the development `CHANGE_ME` Kubernetes secrets with External Secrets/AWS Secrets Manager before using the production overlay.

## Windows support

Windows PowerShell and CMD equivalents are provided:

```text
scripts/start.ps1
scripts/stop.ps1
scripts/seed.ps1
scripts/status.ps1
scripts/build.ps1
scripts/install-windows.ps1
scripts/windows/*.cmd
```

See `scripts/windows/README.md`. Windows uses Kubernetes directly; Docker Compose is not required.

## Image repository strategy

EMTAF supports registry-free local Kubernetes development and configurable cloud OCI registries. See `docs/IMAGE-REPOSITORY-v1.8.md`. Local mode builds `emtaf-*:<tag>` images directly into the Docker engine and uses `IfNotPresent`; cloud mode uses `-Registry` and an explicit push/login step. No registry login is required for local development.
