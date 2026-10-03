# EMTAF v1.11.0 — Domain Web Applications

## Review of supplied v1.10.6 ZIP

The supplied `Updated_EMTAF_SaaS_v1.10.6_Hospital_Param_Typing_Fix.zip` was compared with the previously generated v1.10.6 package. No file-level differences were found in the archive, so the supplied archive is retained as the backend baseline.

The Kubernetes image naming fix is present in the supplied source: build targets use `emtaf-*-service:dev` and the dev overlay references the same names.

## Web applications

Added/reworked five independent domain websites:

- Hospital
- School
- College
- Hotel
- Real Estate

Each site has its own Node server, responsive UI, Dockerfile, README and Kubernetes Deployment/Service.

## Platform integration

- `scripts/build.ps1 -Target all` now includes all five web images.
- Dev Kustomize includes all five web deployments.
- Web NetworkPolicy permits DNS and access to only the corresponding domain-service tier.
- `scripts/start.ps1` waits for the web deployments as well as the backend domain services.
- Existing tenant/JWT/RBAC enforcement remains in the domain APIs.

## Validation

- JavaScript syntax checks pass for all generated web servers and browser application code.
- Kubernetes YAML parses successfully as multi-document YAML.
- Static web artifact smoke-test was added.
- A full Kubernetes rollout and browser/API integration test still requires the user's Docker Desktop/Kubernetes environment and seeded EMTAF database.
