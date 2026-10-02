# EMTAF v1.10.5

## Docker/TypeScript build fix

This release addresses the next strict TypeScript build blocker reported by the Docker build.

### Changes
- Corrected Express application typing in all domain services to retain Express route-handler contextual typing.
- Standardized the shared `run()` wrapper in Hospital, School, College, Hotel, and Real Estate services as an Express `RequestHandler`.
- This prevents route callbacks from degrading to implicit `any` under `strict` TypeScript settings.
- Preserved the existing `Request.emtaf` declaration and tenant-aware query typing.
- Tenant service keeps normal Express route inference.
- Workspace/package versions and local `@emtaf/core` references are aligned at `1.10.5`.

### Evidence from the reported build
- `@emtaf/core@1.10.4` compiled successfully.
- `@emtaf/hospital-service@1.10.4` was the first failing workspace.
- The reported errors were exclusively `TS7006` implicit-`any` errors for Express route callback parameters in `domains/hospital-service/src/main.ts`.

### Validation note
The packaging environment could not complete a full `npm install`/TypeScript compilation within the available execution window, so this package must still be validated with the user's Docker Desktop build. No claim of a completed Docker build is made here.
