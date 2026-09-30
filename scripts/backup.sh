#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL is required}"
out="${1:-artifacts/backups}"; mkdir -p "$out"
stamp=$(date +%Y%m%d-%H%M%S); file="$out/emtaf-$stamp.dump"
pg_dump "$DATABASE_URL" --format=custom --no-owner --file "$file"
sha256sum "$file" > "$file.sha256"
pg_restore --list "$file" >/dev/null
printf 'Backup: %s\nArchive validation: passed\n' "$file"
