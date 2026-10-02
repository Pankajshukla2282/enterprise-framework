# Real estate site (separate from the EMTAF framework)

Static frontend + tiny Node proxy that calls the `realestate-service` API in the
EMTAF Kubernetes cluster with a development JWT.

## Run

1. Port-forward the realestate service:

   ```powershell
   kubectl -n emtaf port-forward svc/realestate-service 8081:80
   ```

2. Mint a dev JWT (requires the Postgres pod, seeded via `scripts/seed.ps1`):

   ```powershell
   node mint-dev-token.mjs realestate.admin@demo.local demo-realestate
   ```

3. Start the site:

   ```powershell
   $env:JWT_TOKEN = "<token from step 2>"
   npm start            # http://localhost:3002
   ```

Configuration: `PORT`, `API_BASE` (default `http://localhost:8081`), `JWT_TOKEN`.
