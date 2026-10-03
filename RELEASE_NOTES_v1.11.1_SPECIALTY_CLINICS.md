# EMTAF SaaS v1.11.1 — Build Fix + Specialty Clinics

## Fixed
- Corrected `scripts/build.ps1` so `*-site` Docker builds use the site directory as their Docker build context. This fixes `COPY public` / `COPY server.mjs` failures shown by Docker Desktop.
- Extended `start.ps1` rollout waiting to include the new specialty sites.

## Hospital specialty capability
Added tenant-scoped hospital-service persistence and APIs for:
- Skin & cosmetic consultations and treatment sessions.
- Cardiac EECP programs and therapy sessions.
- Physiotherapy assessments and therapy sessions.

The existing hospital site exposes these workflows in addition to the general hospital modules.

## Independent sites
- `skin-clinic-site` — port 3006
- `eecp-clinic-site` — port 3007
- `physiotherapy-site` — port 3008

All three are independently buildable/deployable and proxy to the shared `hospital-service`.

## Kubernetes
Added Deployment/Service resources, dev/sandbox/staging/cloud image wiring, and egress NetworkPolicies for the three sites.

## Validation
Static JavaScript and Kubernetes YAML checks should be run before deployment. Full Docker/Kubernetes integration remains environment-dependent.
