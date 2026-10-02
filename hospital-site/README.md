# Hospital site (separate from the EMTAF framework)

Static frontend + tiny Node proxy that calls the `hospital-service` API in the
EMTAF Kubernetes cluster with a development JWT.

## Run

1. Port-forward the hospital service:

   ```powershell
   kubectl -n emtaf port-forward svc/hospital-service 8080:80
   ```

2. Mint a dev JWT (requires the Postgres pod, seeded via `scripts/seed.ps1`):

   ```powershell
   node mint-dev-token.mjs hospital.admin@demo.local demo-hospital
   ```

3. Start the site:

   ```powershell
   $env:JWT_TOKEN = "<token from step 2>"
   npm start            # http://localhost:3001
   ```

Configuration: `PORT`, `API_BASE` (default `http://localhost:8080`), `JWT_TOKEN`.
