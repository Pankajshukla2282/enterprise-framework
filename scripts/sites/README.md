# EMTAF website starters

One starter per website. Each script port-forwards the backing Kubernetes
service to `localhost:8080`, sets `API_BASE`/`PORT`, and runs the site's
`node server.mjs`. Parameters (`-SitePort`, `-ApiPort`, `-Service`,
`-Namespace` on PowerShell; `SITE_PORT`, `API_PORT`, `SERVICE`, `NAMESPACE`
env on bash) override the defaults below.

| Website | Starter | Site port | Backend service |
|---|---|---|---|
| hospital-site | `start-hospital-site` | 3001 | hospital-service |
| school-site | `start-school-site` | 3003 | school-service |
| college-site | `start-college-site` | 3004 | college-service |
| hotel-site | `start-hotel-site` | 3005 | hotel-service |
| realestate-site | `start-realestate-site` | 3002 | realestate-service |
| skin-clinic-site | `start-skin-clinic-site` | 3006 | hospital-service |
| eecp-clinic-site | `start-eecp-clinic-site` | 3007 | hospital-service |
| physiotherapy-site | `start-physiotherapy-site` | 3008 | hospital-service |

`start-all-sites.ps1` / `start-all-sites.sh` runs everything at once
(backends on 8081–8085, sites on their default ports).

```powershell
.\scripts\sites\start-eecp-clinic-site.ps1
.\scripts\sites\start-all-sites.ps1
```

After a site is up: mint a dev token with the **cluster** JWT secret and
paste it into the site's Connect box.

```powershell
$b64 = kubectl -n emtaf get secret emtaf-platform-secrets -o jsonpath="{.data.JWT_SECRET}"
$env:JWT_SECRET = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
npm run token --prefix eecp-clinic-site
```

## Seed data

`scripts/seed/seed-all.sql` covers tenants, users, memberships and the five
domain backends (hospital, school, college, hotel, realestate).
`scripts/seed/seed-specialty-clinics.sql` covers the three specialty sites
(skin, eecp, physio: clinic registry, billing packages, appointments,
consultations/programs/assessments, sessions, invoices, portal profiles).
`scripts/seed.ps1` / `scripts/seed.sh` apply every `seed-*.sql` file in order.
