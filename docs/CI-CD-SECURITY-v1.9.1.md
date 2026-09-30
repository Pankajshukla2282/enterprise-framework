# CI/CD Security Gates

The GitHub Actions workflow `.github/workflows/ci.yml` provides baseline gates for every push/PR:

1. Dependency installation and `npm audit --audit-level=high`.
2. Workspace build.
3. RBAC/security tests.
4. Release smoke tests.
5. PostgreSQL tenant-isolation/idempotency integration tests.
6. Hospital container build.
7. Trivy HIGH/CRITICAL image scan.
8. Gitleaks secret scan.

Before production, add registry signing/verification, SBOM attestation, protected environments, manual production approval and image promotion by digest rather than rebuilding.
