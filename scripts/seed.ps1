[CmdletBinding()]
param(
  [ValidateSet('dev','staging','prod')][string]$Environment = 'dev',
  [string]$Namespace = 'emtaf',
  [string]$PostgresPassword = $(if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { 'emtaf-dev' })
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { throw 'kubectl is required. Install it and ensure it is on PATH.' }
$SeedFile = Join-Path $Root 'scripts\seed\seed-all.sql'
if (-not (Test-Path $SeedFile)) { throw "Seed file not found: $SeedFile" }
$pod = kubectl -n $Namespace get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}'
if ([string]::IsNullOrWhiteSpace($pod)) { throw "PostgreSQL pod not found in namespace $Namespace. Start EMTAF first." }
kubectl -n $Namespace wait --for=condition=Ready "pod/$pod" --timeout=180s | Out-Null
Write-Host "[EMTAF] Seeding sample data into $Namespace ($Environment)..."
$sql = Get-Content -Raw -LiteralPath $SeedFile
# Feed the deterministic SQL through kubectl stdin; the SQL itself is idempotent.
$sql | kubectl -n $Namespace exec -i $pod -- env "PGPASSWORD=$PostgresPassword" psql -U emtaf -d emtaf -v ON_ERROR_STOP=1
Write-Host '[EMTAF] Sample data seeded successfully.'
