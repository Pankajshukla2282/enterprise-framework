# EMTAF on Windows

These scripts target Windows 10/11 using PowerShell 5.1+ or PowerShell 7. Docker Compose is not used.

## Recommended local Kubernetes

Use one of:
- Docker Desktop with Kubernetes enabled
- Rancher Desktop with Kubernetes enabled
- An existing remote Kubernetes cluster

Required CLI tools:
- Node.js 22+
- npm
- kubectl
- Helm

Optional:
- Docker, if you build images locally
- `winget`, for automated installation of the missing CLI tools

## Install/check prerequisites

```powershell
.\scripts\install-windows.ps1
```

Optionally install missing Node.js/kubectl/Helm with Windows Package Manager:

```powershell
.\scripts\install-windows.ps1 -InstallOptionalTools
```

Restart PowerShell after winget installation.

## Start

```powershell
.\scripts\start.ps1 -Environment dev
```

CMD users can run:

```cmd
scripts\windows\start.cmd dev
```

## Seed

```powershell
.\scripts\seed.ps1 -Environment dev
```

## Status

```powershell
.\scripts\status.ps1
```

## Stop

Retain namespace/PVC data:

```powershell
.\scripts\stop.ps1 -Environment dev
```

Purge the namespace and persistent data:

```powershell
.\scripts\stop.ps1 -Environment dev -PurgeData
```

## Build services

Build everything:

```powershell
.\scripts\build.ps1 -Target all
```

Build only Hospital:

```powershell
.\scripts\build.ps1 -Target hospital
```

The `.cmd` wrappers are provided for Command Prompt users.
