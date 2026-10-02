# EMTAF v1.10.6

## Fix
- Fixed Express 5 route-parameter typing in hospital-service where `req.params.id` is typed as `string | string[]` under strict TypeScript.
- Added a reusable route parameter normalizer and applied it to hospital patient ID handlers and audit calls.
- Preserved strict TypeScript; no `any` relaxation was introduced for route parameters.
- Workspace versions aligned to 1.10.6.

## Validation
- Workspace dependency validation passed (8 workspaces).
- School service Docker build was observed succeeding on the preceding v1.10.5 package.
- The remaining hospital failure was reduced to two `TS2345` route-parameter type errors; this release addresses those errors.
- Full Docker build should be run on the Windows Docker Desktop environment.
