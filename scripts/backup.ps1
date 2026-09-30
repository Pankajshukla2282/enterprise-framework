param([string]$OutputDir="artifacts/backups", [switch]$Verify)
$ErrorActionPreference='Stop'
if(-not $env:DATABASE_URL){ throw 'DATABASE_URL is required' }
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$file=Join-Path $OutputDir "emtaf-$stamp.dump"
pg_dump $env:DATABASE_URL --format=custom --no-owner --file $file
$hash=(Get-FileHash $file -Algorithm SHA256).Hash
"$hash  $([IO.Path]::GetFileName($file))" | Set-Content "$file.sha256"
Write-Host "Backup: $file"
if($Verify){ pg_restore --list $file | Out-Null; if($LASTEXITCODE -ne 0){throw 'pg_restore validation failed'}; Write-Host 'Backup archive validation passed.' }
