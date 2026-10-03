const test=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');
const root=path.resolve(__dirname,'..');
const sites=['hospital-site','school-site','college-site','hotel-site','realestate-site','skin-clinic-site','eecp-clinic-site','physiotherapy-site'];
for(const site of sites)test(`${site} web application artifacts`,()=>{
  for(const f of ['package.json','server.mjs','Dockerfile','README.md','public/index.html','public/app.js','public/styles.css'])assert.equal(fs.existsSync(path.join(root,site,f)),true,`${site}/${f} missing`);
  const html=fs.readFileSync(path.join(root,site,'public/index.html'),'utf8');assert.match(html,/EMTAF_CONFIG/);assert.match(html,/app\.js/);
});
test('local web image targets are wired into build script',()=>{
 const s=fs.readFileSync(path.join(root,'scripts','build.ps1'),'utf8');
 for(const x of sites){assert.ok(s.includes(`emtaf-${x}`),`${x} image target missing`);assert.ok(s.includes(`${x}/Dockerfile`),`${x} Dockerfile target missing`)}
});
