const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

function readJson(file) { return JSON.parse(fs.readFileSync(file, 'utf8')); }
const root = readJson(path.join(process.cwd(), 'package.json'));
const workspaceDirs = [];
for (const pattern of root.workspaces || []) {
  if (pattern === 'core') workspaceDirs.push('core');
  else if (pattern.endsWith('/*')) {
    const base = pattern.slice(0, -2);
    for (const name of fs.readdirSync(base)) {
      const dir = path.join(base, name);
      if (fs.existsSync(path.join(dir, 'package.json'))) workspaceDirs.push(dir);
    }
  }
}
const local = new Map();
for (const dir of workspaceDirs) {
  const file = path.join(dir, 'package.json');
  const pkg = readJson(file);
  local.set(pkg.name, pkg.version);
}
const problems = [];
for (const dir of workspaceDirs) {
  const file = path.join(dir, 'package.json');
  const pkg = readJson(file);
  for (const section of ['dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies']) {
    for (const [name, requested] of Object.entries(pkg[section] || {})) {
      if (!local.has(name)) continue;
      const actual = local.get(name);
      if (requested !== actual && requested !== `workspace:${actual}` && requested !== `workspace:*`) {
        problems.push(`${file}: ${name} requests ${requested}, local workspace is ${actual}`);
      }
    }
  }
}
if (problems.length) {
  console.error('Workspace dependency validation failed:');
  console.error(problems.join('\n'));
  process.exit(1);
}
console.log(`Workspace dependency validation passed (${local.size} workspaces).`);
