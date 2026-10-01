# EMTAF SaaS v1.10.2

## Docker/workspace build fix

This release fixes the Docker build failure caused by stale local workspace versions and an unavailable OpenTelemetry dependency range.

### Changes
- Synchronized all `@emtaf/core` workspace consumers to `1.10.2`.
- Updated root/core/domain/tenant package versions to `1.10.2`.
- Removed redundant direct OpenTelemetry Express/HTTP/PG instrumentation dependencies from `@emtaf/core`; the project already uses `@opentelemetry/auto-instrumentations-node`.
- Kept the OpenTelemetry SDK/resource versions used by the existing telemetry implementation.
- Docker npm installation now uses `--include=dev --ignore-scripts --no-audit --no-fund`.
- `scripts/build.ps1` now runs workspace validation before building images.
- Existing `scripts/validate-workspaces.js` remains the preflight guard against accidental registry resolution of local EMTAF workspaces.

## Verification

From the repository root:

```powershell
npm run test:workspace-config
.\scripts\build.ps1 -Mode local -Target all
```
