#!/usr/bin/env bash
set -euo pipefail
: "${VERIFY_DATABASE_URL:?VERIFY_DATABASE_URL is required}"
backup="${1:?backup file required}"
pg_restore --clean --if-exists --no-owner --dbname "$VERIFY_DATABASE_URL" "$backup"
psql "$VERIFY_DATABASE_URL" -v ON_ERROR_STOP=1 -c 'select 1 from tenants limit 1;' >/dev/null
echo 'DR restore verification passed.'
