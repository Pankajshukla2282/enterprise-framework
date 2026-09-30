const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const domains = ['hospital-service','school-service','college-service','hotel-service','realestate-service'];
for (const d of domains) {
  test(`${d} has service-local documentation and scripts`, () => {
    for (const f of ['README.md','DEPLOYMENT.md','RUNBOOK.md']) assert.ok(fs.existsSync(path.join(root,'domains',d,f)), `${d}/${f}`);
    for (const f of ['build.ps1','build.sh','deploy.ps1','deploy.sh','status.ps1','status.sh','stop.ps1','stop.sh','seed.ps1','seed.sh']) assert.ok(fs.existsSync(path.join(root,'domains',d,'scripts',f)), `${d}/scripts/${f}`);
  });
}
test('core has service-local docs and scripts', () => { for (const f of ['README.md','DEPLOYMENT.md','RUNBOOK.md']) assert.ok(fs.existsSync(path.join(root,'core',f))); });
test('root release clutter is consolidated', () => {
  for (const f of ['README_v1.7.md','README_v1.8.md','RELEASE_NOTES_v1.1.md','RELEASE_NOTES_v1.2-v1.5.md','RELEASE_NOTES_v1.6.md','RELEASE_NOTES_v1.7.md','RELEASE_NOTES_v1.8.1_IMAGE_REPOSITORY.md','DEPLOYMENT.md','QUICKSTART_TWO_SERVICES.md']) assert.equal(fs.existsSync(path.join(root,f)), false, f);
  assert.equal(fs.existsSync(path.join(root,'CHANGELOG.md')), true);
});
