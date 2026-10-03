# EMTAF local startup sequence

Full order to bring the platform, demo data, and all eight websites up on a
local machine against the `dev` Kubernetes overlay. Run top to bottom.

## 0. Prerequisites

`kubectl` (pointing at the dev cluster), `node >= 22`, and the repo root as
the working directory. All PowerShell commands run from the repo root.

## 1. (Optional) Build images

```powershell
.\scripts\build.ps1 -Target all -Mode local
```

| Parameter | Values | Default | Notes |
|---|---|---|---|
| `-Target` | `all`, `hospital`, `school`, `college`, `hotel`, `realestate`, `tenant`, `demo`, `migrations`, `<site>`… | `all` | `<site>` = `hospital-site`, `school-site`, `college-site`, `hotel-site`, `realestate-site`, `skin-clinic-site`, `eecp-clinic-site`, `physiotherapy-site` |
| `-Mode` | `local`, `cloud` | `local` | `cloud` also needs `-Registry`, `-Tag` |

Skip this if images are already built; `start.ps1` uses `IfNotPresent`.

## 2. Start the platform

```powershell
.\scripts\start.ps1 -Environment dev -ImageMode local
```

| Parameter | Values | Default | Notes |
|---|---|---|---|
| `-Environment` | `dev`, `staging`, `prod` | `dev` | Selects `infra/kubernetes/overlays/<env>` |
| `-ImageMode` | `local`, `cloud` | `local` | `cloud` requires `-Registry` (and `-ManagedPlatformCidr` for staging/prod) |
| `-Registry` | e.g. `ghcr.io/your-org` | `''` | Container registry for `cloud` mode |
| `-Tag` | image tag | `dev` | Applied to generated manifests in `cloud` mode |
| `-Namespace` | k8s namespace | `emtaf` | `emtaf-training` for sandbox scripts |
| `-VerifySignatures` | switch | off | `cloud` mode only; runs `verify-images.ps1` |

This applies the overlay, waits for `postgres`/`redis`/`redpanda`, runs the
`emtaf-migrations` job, then waits for every service deployment.

## 3. Seed demo data

```powershell
.\scripts\seed.ps1 -Environment dev
```

Applies every `scripts/seed/seed-*.sql` in order: `seed-all.sql` (tenants,
users, memberships, hospital/school/college/hotel/realestate rows) then
`seed-specialty-clinics.sql` (skin/eecp/physio clinics, packages,
appointments, consultations/programs/assessments, sessions, invoices, portal
profiles). Idempotent — safe to re-run.

| Parameter | Values | Default |
|---|---|---|
| `-Environment` | `dev`, `staging`, `prod`, `sandbox` | `dev` |
| `-Namespace` | k8s namespace | `emtaf` (`emtaf-training` for `sandbox`) |
| `-PostgresPassword` | DB password | `$env:POSTGRES_PASSWORD`, else `emtaf-dev` |

## 4. Start the websites

Single site (port-forwards its backend to `localhost:8080`, then serves the
site; `Ctrl+C` stops both):

```powershell
.\scripts\sites\start-eecp-clinic-site.ps1
.\scripts\sites\start-eecp-clinic-site.ps1 -SitePort 3007 -ApiPort 8080 -Service hospital-service -Namespace emtaf
```

| Parameter | Default (single-site) | Notes |
|---|---|---|
| `-SitePort` | site default (3001–3008) | Website `http://localhost:<port>` |
| `-ApiPort` | `8080` | Local end of the `svc/<service>:80` port-forward; `API_BASE` points here |
| `-Service` | site's backend service | `hospital-service` for hospital + all 3 clinic sites |
| `-Namespace` | `emtaf` | Where the backend service runs |

All eight at once (backends on 8081–8085, sites on default ports):

```powershell
.\scripts\sites\start-all-sites.ps1
.\scripts\sites\start-all-sites.ps1 -Namespace emtaf
```

| Site | URL | Backend via |
|---|---|---|
| hospital-site | http://localhost:3001 | hospital-service :8081 |
| school-site | http://localhost:3003 | school-service :8082 |
| college-site | http://localhost:3004 | college-service :8083 |
| hotel-site | http://localhost:3005 | hotel-service :8084 |
| realestate-site | http://localhost:3002 | realestate-service :8085 |
| skin-clinic-site | http://localhost:3006 | hospital-service :8081 |
| eecp-clinic-site | http://localhost:3007 | hospital-service :8081 |
| physiotherapy-site | http://localhost:3008 | hospital-service :8081 |

Bash equivalents: `scripts/sites/start-<site>.sh`, `scripts/sites/start-all-sites.sh`
(`SITE_PORT`, `API_PORT`, `SERVICE`, `NAMESPACE` env vars).

## 5. Connect (per site)

1. Export the **cluster** JWT secret (the minter's fallback secret does NOT
   match the cluster — tokens minted without this always 401):
   ```powershell
   $b64 = kubectl -n emtaf get secret emtaf-platform-secrets -o jsonpath="{.data.JWT_SECRET}"
   $env:JWT_SECRET = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
   npm run token --prefix eecp-clinic-site
   ```
   Token identities: hospital sites → `hospital.admin@demo.local` /
   `demo-hospital`; school/college/hotel/realestate → `<domain>.admin@demo.local` /
   `demo-<domain>`.
2. Open the site URL, paste the token into the **Connect** box (top bar,
   "Paste JWT token"), click Connect.
3. Hard-refresh once (`Ctrl+Shift+R`) after updating the repo so the browser
   picks up the current `public/app.js`.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `502`, `{"error":"..."}` from `/api/...` | No port-forward on `API_BASE` | Run the site starter (step 4), don't run `node server.mjs` bare |
| `401 Missing bearer token` | Connect box empty | Step 5 |
| `401 Invalid authentication token` | Token signed with wrong secret / expired | Re-mint with cluster `JWT_SECRET` (step 5.1) |
| `403 Tenant membership denied` | User not a tenant member | Re-run `seed.ps1` |
| Request URL contains `/api/api/...` | Cached old `app.js` | Hard-refresh / restart the site server |
