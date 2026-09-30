#!/bin/sh
set -eu
until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do sleep 2; done
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/001-platform.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/002-domains.sql
for f in /app/domains/*/migrations/*.sql; do
  [ -f "$f" ] || continue
  echo "Applying $f"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/005-production-hardening.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/003-rls.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/006-production-grade-events.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/006-production-grade-events.sql
if [ "${EMTAF_BOOTSTRAP_DEMO:-false}" = "true" ]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /app/infra/postgres/004-bootstrap.sql
fi
