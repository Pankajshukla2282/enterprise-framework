# EMTAF SaaS v1.10.4 — Domain TypeScript/Docker Build Fix

## Fixes

- Corrected Express application typing in tenant and all domain services so `app.get/app.post/app.patch/app.delete` route callbacks receive Express `Request`/`Response` types under strict TypeScript.
- Typed the tenant-aware query helpers to prevent PostgreSQL query results from becoming `unknown` during strict compilation.
- Retained the `Express.Request.emtaf` declaration in every service.
- Kept `@types/cors` in every service devDependencies.
- Kept local workspace dependency validation and aligned all EMTAF workspace versions to 1.10.4.
- Preserved the Docker build sequence: install dev dependencies, build `@emtaf/core`, build the target service, then prune dev dependencies.

## Validation

- Workspace dependency validation: PASS (8 package workspaces discovered).
- JSON package metadata validation: PASS.
- Stale `@emtaf/core@1.0.0` references: none expected.
- Stale OpenTelemetry Express `^0.47.2` reference: none expected.
- Docker build was not executed in the packaging environment; run `./scripts/build.ps1 -Mode local -Target all` on Docker Desktop Windows.
