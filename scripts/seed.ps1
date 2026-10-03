[CmdletBinding()]
param(
  [ValidateSet('dev','staging','prod','sandbox')][string]$Environment = 'dev',
  [string]$Namespace = $(if ($Environment -eq 'sandbox') { 'emtaf-training' } else { 'emtaf' }),
  [string]$PostgresPassword = $(if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { 'emtaf-dev' })
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { throw 'kubectl is required. Install it and ensure it is on PATH.' }
$SeedFiles = Get-ChildItem -LiteralPath (Join-Path $Root 'scripts\seed') -Filter 'seed-*.sql' | Sort-Object Name
if (-not $SeedFiles) { throw "No seed files found in scripts\seed" }
$pod = kubectl -n $Namespace get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}'
if ([string]::IsNullOrWhiteSpace($pod)) { throw "PostgreSQL pod not found in namespace $Namespace. Start EMTAF first." }
kubectl -n $Namespace wait --for=condition=Ready "pod/$pod" --timeout=180s | Out-Null
Write-Host "[EMTAF] Seeding sample data into $Namespace ($Environment)..."
foreach ($SeedFile in $SeedFiles) {
Write-Host "[EMTAF] Applying $($SeedFile.Name)..."
$sql = Get-Content -Raw -LiteralPath $SeedFile.FullName
# Feed the deterministic SQL through kubectl stdin; the SQL itself is idempotent.
$sql | kubectl -n $Namespace exec -i $pod -- env "PGPASSWORD=$PostgresPassword" psql -U emtaf -d emtaf -v ON_ERROR_STOP=1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Seed SQL failed ($($SeedFile.Name), psql exit code $LASTEXITCODE). Sample data was NOT fully applied."
  exit $LASTEXITCODE
}
}
Write-Host '[EMTAF] Sample data seeded successfully.'
