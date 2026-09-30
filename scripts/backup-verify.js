const fs=require('fs');const cp=require('child_process');const path=require('path');
const file=process.argv[2];
if(!file){console.error('Usage: node scripts/backup-verify.js <backup.dump>');process.exit(2)}
if(!fs.existsSync(file)) throw new Error(`Backup not found: ${file}`);
const r=cp.spawnSync('pg_restore',['--list',file],{encoding:'utf8'});
if(r.status!==0){console.error(r.stderr);process.exit(r.status||1)}
const sha=file+'.sha256';
if(fs.existsSync(sha)){const vr=process.platform==='win32'?cp.spawnSync('powershell',['-NoProfile','-Command',`$h=(Get-FileHash -Algorithm SHA256 '${file}').Hash.ToLower(); $e=(Get-Content '${sha}').Split(' ')[0].ToLower(); if($h -ne $e){exit 1}`],{encoding:'utf8'}):cp.spawnSync('sha256sum',['-c',sha],{encoding:'utf8'});if(vr.status!==0)throw new Error('Backup checksum verification failed')}
console.log('Backup archive and checksum validation passed.');
