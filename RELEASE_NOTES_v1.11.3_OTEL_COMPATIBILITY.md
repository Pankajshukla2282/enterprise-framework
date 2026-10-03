# EMTAF SaaS v1.11.3 — OpenTelemetry Compatibility Fix

## Build failure fixed

Docker builds were failing in `core/src/telemetry.ts` with either:

- `TS2693: 'Resource' only refers to a type, but is being used as a value here`
- `TS2724: '@opentelemetry/resources' has no exported member 'resourceFromAttributes'`

The root cause was mixing the OpenTelemetry resources API generation with the EMTAF SDK dependency line.

## Correction

EMTAF core now pins the OpenTelemetry packages to the compatible 1.x/0.57.x line and uses the `Resource` constructor:

- `@opentelemetry/api` 1.9.0
- `@opentelemetry/sdk-node` 0.57.2
- `@opentelemetry/exporter-trace-otlp-http` 0.57.2
- `@opentelemetry/auto-instrumentations-node` 0.56.0
- `@opentelemetry/resources` 1.30.1
- `@opentelemetry/semantic-conventions` 1.28.0

Versions are exact rather than caret ranges because the Docker build intentionally installs from package manifests and the repository does not rely on a lockfile in the image build context.

## Specialty products retained

This release retains the true specialty products introduced in v1.11.2:

- Skin & Cosmetics clinic
- Cardiac EECP therapy clinic
- Physiotherapy & Rehabilitation clinic

Each has separate dashboard/site, specialty RBAC, workflow states, clinical forms, billing packages, reports, patient portal and training/demo data, while sharing the tenant-isolated EMTAF hospital platform.
