# EMTAF Database Migrations

Migrations are applied in this order:

1. `001-platform.sql`
2. `002-domains.sql`
3. every domain migration under `domains/*/migrations/*.sql`
4. `005-production-hardening.sql` — idempotency, transactional outbox and backup metadata
5. `003-rls.sql` — FORCE RLS tenant isolation
6. `004-bootstrap.sql` only when demo bootstrap is explicitly enabled

`005-production-hardening.sql` must precede `003-rls.sql` so the new platform tables receive the correct security configuration.
