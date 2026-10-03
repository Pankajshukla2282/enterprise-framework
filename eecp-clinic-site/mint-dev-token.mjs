#!/usr/bin/env node
// Minimal JWT HS256 token minter for local EMTAF development.
// Usage: node scripts/mint-dev-token.mjs <email> <tenant-code> [api-base]
import { execFileSync } from 'node:child_process';
import { createHmac } from 'node:crypto';
import fs from 'node:fs';

const [,, email, tenantCode] = process.argv;
if (!email || !tenantCode) {
  console.error('Usage: node mint-dev-token.mjs <email> <tenant-code>');
  process.exit(2);
}
const JWT_SECRET =
  process.env.JWT_SECRET ||
  'local-development-only-please-change-this-to-a-strong-value';

function sql(q) {
  return execFileSync('kubectl', [
    'exec', '-n', 'emtaf', 'deploy/postgres', '--',
    'psql', '-U', 'emtaf', '-d', 'emtaf', '-tA', '-c', q,
  ]).toString().trim();
}
const userId = sql(`SELECT id FROM users WHERE email='${email}' LIMIT 1`);
const tenantId = sql(`SELECT id FROM tenants WHERE code='${tenantCode}' LIMIT 1`);
if (!userId || !tenantId) {
  console.error('User or tenant not found. Run .\\scripts\\seed.ps1 first.');
  process.exit(1);
}
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
const header = b64({ alg: 'HS256', typ: 'JWT' });
const payload = b64({
  sub: userId,
  tenantId,
  email,
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + 60 * 60 * 12,
});
const sig = createHmac('sha256', JWT_SECRET).update(`${header}.${payload}`).digest('base64url');
console.log(`${header}.${payload}.${sig}`);
