const test=require('node:test'); const assert=require('node:assert/strict'); const fs=require('fs'); const path=require('path');
const root=path.resolve(__dirname,'..');
function read(p){return fs.readFileSync(path.join(root,p),'utf8')}
test('production overlay does not use development secrets',()=>{const s=read('infra/kubernetes/overlays/prod/kustomization.yaml');assert.doesNotMatch(s,/secret-patch|emtaf-dev|CHANGE_ME/);});
test('production template requires operator-supplied managed endpoints',()=>{const c=read('infra/kubernetes/overlays/prod/external-config.yaml');assert.match(c,/SET_BY_OPERATOR/);const ps=read('scripts/start.ps1');assert.match(ps,/Unresolved production deployment placeholders/);});
test('production uses external platform endpoints',()=>{const s=read('infra/kubernetes/overlays/prod/kustomization.yaml')+read('infra/kubernetes/overlays/prod/external-config.yaml')+read('infra/kubernetes/overlays/prod/external-secrets.yaml');assert.match(s,/external-platform-config/);assert.match(s,/emtaf-platform-secrets/);});
test('outbox has leases and consumer dedupe',()=>{const s=read('infra/postgres/006-production-grade-events.sql');assert.match(s,/locked_at/);assert.match(s,/platform_consumed_events/);assert.match(s,/CREATE TRIGGER/);});
test('CI has image signing and SBOM gates',()=>{const s=read('.github/workflows/ci.yml');assert.match(s,/cosign/i);assert.match(s,/sbom/i);assert.match(s,/gitleaks/i);});
