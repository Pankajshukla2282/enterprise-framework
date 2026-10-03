# EMTAF SaaS v1.11.2 — Build Fix + True Specialty Clinic Products

## Build failure fixed
The reported Docker/TypeScript failure was caused by `core/src/telemetry.ts` constructing `new Resource(...)` while the installed `@opentelemetry/resources` API exposes `resourceFromAttributes(...)`. The telemetry implementation now uses the compatible factory.

The build context correction from v1.11.1 remains in place: every `*-site` Docker image is built with its own site directory as context, so `COPY package.json server.mjs ./` and `COPY public ./public` resolve correctly.

Also removed the duplicate invocation of `006-production-grade-events.sql` from the migration runner.

## True specialty products
Skin & Cosmetics, Cardiac EECP Therapy and Physiotherapy are now treated as specialty clinic products rather than only hospital modules.

### Skin & Cosmetics
- Dedicated site: `skin-clinic-site` (3006)
- Dermatology/skin consultation workflow
- Cosmetic treatment/session workflow
- Specialty appointments and workflow states
- Billing packages and invoices
- Reports
- Patient portal
- Specialty RBAC: `skin_admin`, `dermatologist`, `aesthetician`, `skin_nurse`, `skin_receptionist`, `skin_billing`, `skin_patient`

### Cardiac EECP Therapy
- Dedicated site: `eecp-clinic-site` (3007)
- EECP programme management
- Therapy sessions with pre/post observations
- Screening/scheduling/in-progress/completion workflow
- Specialty appointments
- Billing packages/invoices
- Reports
- Patient portal
- Specialty RBAC: `eecp_admin`, `cardiologist`, `eecp_therapist`, `eecp_nurse`, `eecp_receptionist`, `eecp_billing`, `eecp_patient`

### Physiotherapy & Rehabilitation
- Dedicated site: `physiotherapy-site` (3008)
- Physiotherapy assessment
- Goals, precautions, treatment plan
- Therapy sessions, exercises, modalities and home programme
- Specialty appointments
- Billing packages/invoices
- Reports
- Patient portal
- Specialty RBAC: `physio_admin`, `physiotherapist`, `physio_assistant`, `physio_receptionist`, `physio_billing`, `physio_patient`

## Persistence
Added `domains/hospital-service/migrations/004_specialty_productization.sql` for:
- specialty clinic configuration
- specialty appointments
- specialty billing packages
- specialty invoices
- specialty patient portal profiles

Existing specialty clinical tables remain tenant-scoped and are covered by RLS.

## Demo/training data
The local bootstrap now creates specialty clinic configurations and representative billing packages for the `demo-hospital` tenant.

## Validation completed
- Workspace dependency validation: passed (8 workspaces)
- Website/static regression tests: 13/13 passed
- Specialty site configuration validation: passed
- Telemetry compatibility regression test: passed

A full Docker build must still be executed on the user's Docker Desktop host; the packaging environment does not expose the Docker CLI/daemon.
