# EMTAF Physiotherapy Clinic

Multi-tenant physiotherapy assessment and rehabilitation portal. This is a separate EMTAF site backed by the tenant-scoped `hospital-service` specialty APIs.

## Local

Run `.\scripts\sites\start-physiotherapy-site.ps1` from the repo root (default port `3008`; port-forwards `hospital-service`, `Ctrl+C` stops both). Equivalent manual flow: `npm start` with `API_BASE` pointing at the port-forwarded `hospital-service`.

Mint a token with the cluster JWT secret and paste it into the site Connect box. Full sequence with parameters: `docs/LOCAL_STARTUP.md`.

The browser uses a same-origin `/api` proxy and forwards the JWT. Authorization and tenant isolation remain enforced by EMTAF.
