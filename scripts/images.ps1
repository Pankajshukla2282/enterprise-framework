[CmdletBinding()]
param(
  [ValidateSet('save','load','list')][string]$Action='list',
  [string]$Directory='./artifacts/images',
  [string]$Tag='dev',
  [switch]$IncludePlatform
)
$ErrorActionPreference='Stop'
if(-not(Get-Command docker -ErrorAction SilentlyContinue)){throw 'Docker is required.'}
$names=@('tenant-service','hospital-service','school-service','college-service','hotel-service','realestate-service','demo-wireframe','migrations') | ForEach-Object { "emtaf-$_`:$Tag" }
if($IncludePlatform){$names += @('postgres:16-alpine','redis:7-alpine','docker.redpanda.com/redpandadata/redpanda:v24.3.5','node:22-alpine','nginx:1.27-alpine')}
if($Action -eq 'list'){ $names | ForEach-Object { docker image inspect $_ --format '{{.RepoTags}}' 2>$null }; exit 0 }
if($Action -eq 'save'){
 New-Item -ItemType Directory -Force -Path $Directory | Out-Null
 foreach($image in $names){ docker image inspect $image *> $null; if($LASTEXITCODE -ne 0){throw "Image not found locally: $image"}; $safe=($image -replace '[/:]','_'); docker save -o (Join-Path $Directory "$safe.tar") $image }
 Write-Host "Saved images to $Directory"
 exit 0
}
Get-ChildItem $Directory -Filter '*.tar' | ForEach-Object { docker load -i $_.FullName }
