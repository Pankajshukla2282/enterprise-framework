# Platform Operations Scripts

Root scripts operate the complete EMTAF platform. Each core/domain service also contains service-local scripts for build, deploy, status, stop and seed workflows.

Windows: PowerShell scripts in this directory plus CMD wrappers under `windows/`.
Linux/macOS: Bash scripts in this directory and `linux/`.

For service-specific operations, prefer the scripts next to that service.

## Production hardening operations

- `backup.ps1` / `backup.sh` create PostgreSQL custom-format backups and validate the archive.
- `restore-verify.ps1` / `restore-verify.sh` restore into a disposable verification database.
- `start-sandbox.ps1` / `start-sandbox.sh` deploy the isolated `emtaf-training` namespace.
- `stop-sandbox.ps1` / `stop-sandbox.sh` tear down the training namespace.

Critical Hospital writes use tenant-scoped idempotency and transactional outbox events. The outbox worker is deployed as `emtaf-outbox-worker`.
