#!/usr/bin/env bash
set -euo pipefail
: "${VERIFY_DATABASE_URL:?VERIFY_DATABASE_URL is required and must point to a disposable verification database}"
backup="${1:?backup file required}"
pg_restore --clean --if-exists --no-owner --dbname "$VERIFY_DATABASE_URL" "$backup"
printf 'Restore verification passed.\n'
