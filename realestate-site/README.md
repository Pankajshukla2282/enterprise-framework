# EMTAF Real Estate Management

Independent EMTAF web application for the `realestate` domain. It is a browser UI over the domain service API and uses the same tenant/JWT security boundary as the backend.

## Local development

1. Start the platform and seed demo data: `.\scripts\start.ps1 -Environment dev -ImageMode local`, then `.\scripts\seed.ps1 -Environment dev`.
2. Run `.\scripts\sites\start-realestate-site.ps1` from the repo root (port-forwards `realestate-service` and serves this site; `Ctrl+C` stops both). Equivalent manual flow: port-forward the domain service to `API_BASE` (default `http://localhost:8080`) and run `npm start`.
3. Mint a token with the cluster JWT secret (`npm run token` — see `docs/LOCAL_STARTUP.md`) and paste it into the site Connect box.

Full sequence with parameters: `docs/LOCAL_STARTUP.md`.

Default site port: `3002`.

## Configuration

`PORT` controls the website port and `API_BASE` points at the port-forwarded domain API. The browser stores only the JWT in local storage; the Node server proxies API requests without embedding a server-side token.

## Functionality

Dashboard, tenant identity, searchable data grids, create forms, workflow actions, and role/permission enforcement are provided through the domain API. The UI intentionally does not bypass backend authorization.
