[CmdletBinding()]
param(
  [ValidateSet('all','hospital','school','college','hotel','realestate','tenant','demo','migrations')][string]$Target='all',
  [ValidateSet('local','cloud')][string]$Mode='local',
  [string]$Registry='',
  [string]$Tag='dev',
  [switch]$Push,
  [switch]$Load,
  [switch]$Provenance
)
$ErrorActionPreference='Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $Root
if (Get-Command node -ErrorAction SilentlyContinue) { node ./scripts/validate-workspaces.js } else { throw 'Node.js is required for workspace validation.' }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker is required.' }
$targets = if ($Target -eq 'all') { @('tenant','hospital','school','college','hotel','realestate','demo','migrations') } else { @($Target) }
$map=@{tenant='services/tenant-service/Dockerfile';hospital='domains/hospital-service/Dockerfile';school='domains/school-service/Dockerfile';college='domains/college-service/Dockerfile';hotel='domains/hotel-service/Dockerfile';realestate='domains/realestate-service/Dockerfile';demo='demo-wireframe/Dockerfile';migrations='infra/migrations/Dockerfile'}
foreach($name in $targets){
  $repo = switch($name){
    'tenant'{'emtaf-tenant-service'}
    'hospital'{'emtaf-hospital-service'}
    'school'{'emtaf-school-service'}
    'college'{'emtaf-college-service'}
    'hotel'{'emtaf-hotel-service'}
    'realestate'{'emtaf-realestate-service'}
    'demo'{'emtaf-demo-wireframe'}
    'migrations'{'emtaf-migrations'}
  }
  $image = if($Mode -eq 'cloud') { if([string]::IsNullOrWhiteSpace($Registry)){throw 'Registry is required in cloud mode. Use -Registry ghcr.io/your-org (or your ECR/ACR/GAR repository).'} else { "$Registry/$repo`:$Tag" } } else { "$repo`:$Tag" }
  Write-Host "[EMTAF] Building $image"
  docker build --provenance=$($Provenance.ToString().ToLower()) --sbom=$($Provenance.ToString().ToLower()) -f $map[$name] -t $image .
  if($Load -and $Mode -eq 'local') {
    if(Get-Command kind -ErrorAction SilentlyContinue){ docker image inspect $image | Out-Null; kind load docker-image $image }
    elseif(Get-Command minikube -ErrorAction SilentlyContinue){ minikube image load $image }
    else { Write-Host '[EMTAF] Docker Desktop Kubernetes uses the local Docker image directly; no image load required.' }
  }
  if($Push){ if($Mode -ne 'cloud'){throw '-Push requires -Mode cloud.'}; docker push $image }
}
