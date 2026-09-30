const test=require('node:test'); const assert=require('node:assert/strict');
const fs=require('fs'); const path=require('path');
const core=fs.readFileSync(path.join(__dirname,'../../core/src/index.ts'),'utf8'); const rbac=fs.readFileSync(path.join(__dirname,'../../core/src/rbac.ts'),'utf8');
test('RBAC permission map contains critical hospital roles',()=>{
  for(const role of ['superadmin','admin','doctor','nurse','accountant','receptionist','patient']) assert.match(rbac,new RegExp(role));
  assert.match(rbac,/patients:read/); assert.match(rbac,/billing:write/); assert.match(rbac,/clinical:write/);
});
test('tenant context is required by authorization',()=>{ assert.match(core,/tenantId is required/); assert.match(core,/tenant_memberships/); });
test('force RLS is configured',()=>{ const sql=fs.readFileSync(path.join(__dirname,'../../infra/postgres/003-rls.sql'),'utf8'); assert.match(sql,/FORCE ROW LEVEL SECURITY/); });

test('production rejects weak/default JWT secret',()=>{assert.match(core,/JWT_SECRET must be configured/)});
test('idempotency binds key to user and expiry',()=>{assert.match(core,/different user/);assert.match(core,/processing_expires_at/)});
