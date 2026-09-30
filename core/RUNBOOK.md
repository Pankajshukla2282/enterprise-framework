# EMTAF Core Runbook

## Responsibilities

- authentication and tenant context
- membership-based authorization
- tenant-aware database access
- Redis primitives
- event-bus contracts
- audit foundation

## Incident checks

1. Verify JWT validation and tenant context.
2. Verify the user's active membership in the requested tenant.
3. Verify permission evaluation.
4. Verify PostgreSQL connectivity and RLS context.
5. Verify Redis and event-bus connectivity.

Never bypass tenant authorization or disable RLS as a production troubleshooting shortcut.
