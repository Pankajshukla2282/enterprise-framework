param([Parameter(Mandatory=$true)][string]$BackupFile)
$ErrorActionPreference='Stop'
if(-not $env:VERIFY_DATABASE_URL){ throw 'VERIFY_DATABASE_URL is required and must point to a disposable verification database' }
pg_restore --clean --if-exists --no-owner --dbname $env:VERIFY_DATABASE_URL $BackupFile
if($LASTEXITCODE -ne 0){ throw 'Restore verification failed' }
Write-Host 'Restore verification passed.'
