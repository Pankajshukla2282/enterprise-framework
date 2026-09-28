# EMTAF demo wireframe

A dependency-free, responsive browser wireframe for demonstrating the five EMTAF domains:

- Hospital
- School
- College
- Hotel
- Real Estate

It includes tenant switching, domain-specific navigation, role switching, dashboard metrics, activity, tables, and simulated actions.

## Run

From this folder:

```bash
python3 -m http.server 8080
```

Then open `http://localhost:8080`.

The wireframe is intentionally static/demo-first; it does not invent an authentication flow. It can later be connected to the EMTAF API Gateway by replacing the demo data layer in `app.js` with fetch calls to the corresponding `/api/v1/<domain>/...` endpoints.
