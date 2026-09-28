# EMTAF v1.7 operations and demo

This release adds the operational layer needed to run the multi-tenant platform as a Kubernetes-only demo environment.

## Start

```bash
./scripts/start.sh dev
./scripts/seed.sh dev
./scripts/status.sh
```

## Stop

```bash
./scripts/stop.sh dev
```

The default teardown retains the namespace/data. Explicitly purge it with:

```bash
./scripts/stop.sh dev --purge-data
```

## Sample data

The seed is repeatable and covers all five domain services:

- Hospital
- School
- College
- Hotel
- Real Estate

## Wireframe

`demo-wireframe/` is a dependency-free responsive UI demo. It simulates tenant switching, domain switching, RBAC role switching, dashboards, record lists and actions. It can be served directly or packaged into the included nginx image for Kubernetes.

```bash
cd demo-wireframe
python3 -m http.server 8080
```

## Windows development support

EMTAF supports both Linux/macOS shell workflows and Windows 10/11. Windows developers can use PowerShell 5.1+ or PowerShell 7 with `scripts/*.ps1`, or Command Prompt wrappers under `scripts/windows/*.cmd`.

Recommended local Kubernetes options are Docker Desktop with Kubernetes enabled or Rancher Desktop with Kubernetes enabled. Docker Compose is not used by EMTAF.

Windows prerequisite helper:

```powershell
.\scripts\install-windows.ps1
```

Start/seed/stop:

```powershell
.\scripts\start.ps1 -Environment dev
.\scripts\seed.ps1 -Environment dev
.\scripts\stop.ps1 -Environment dev
```

Build services:

```powershell
.\scripts\build.ps1 -Target all
```
