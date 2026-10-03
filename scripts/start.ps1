[CmdletBinding()]
param(
  [ValidateSet('dev','staging','prod')][string]$Environment='dev',
  [ValidateSet('local','cloud')][string]$ImageMode='local',
  [string]$Registry='',
  [string]$Tag='dev',
  [string]$Namespace='emtaf',
  [string]$ManagedPlatformCidr='',
  [string]$SecretStoreName='emtaf-secret-store',
  [switch]$VerifySignatures
)
$ErrorActionPreference='Stop'
$Root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
function Require([string]$n){if(-not(Get-Command $n -ErrorAction SilentlyContinue)){throw "$n is required."}}
Require kubectl
$overlay=Join-Path $Root "infra\kubernetes\overlays\$Environment"
if($ImageMode -eq 'cloud'){
 if([string]::IsNullOrWhiteSpace($Registry)){throw 'Cloud image mode requires -Registry, e.g. -Registry ghcr.io/your-org'}
 $gen=Join-Path $Root ('infra\kubernetes\overlays\.generated\'+$Environment)
 if(Test-Path $gen){Remove-Item $gen -Recurse -Force}
 New-Item -ItemType Directory -Force -Path $gen | Out-Null
 Copy-Item (Join-Path $overlay '*') $gen -Recurse -Force
 $files=Get-ChildItem $gen -Recurse -File | Where-Object { $_.Extension -in '.yaml','.yml' }
 foreach($f in $files){
   $content=Get-Content $f.FullName -Raw
   $content=$content.Replace('REGISTRY/',$Registry.TrimEnd('/')+'/').Replace('IMAGE_TAG',$Tag).Replace('REPLACE_WITH_MANAGED_PLATFORM_CIDR',$ManagedPlatformCidr).Replace('emtaf-secret-store',$SecretStoreName)
   $content=$content.Replace('- ../../base', '- ../../../base')
   Set-Content $f.FullName $content -Encoding utf8
 }
 if($Environment -in @('prod','staging')){
   if([string]::IsNullOrWhiteSpace($ManagedPlatformCidr)){throw 'Staging/prod cloud deployment requires -ManagedPlatformCidr for PostgreSQL/Redis/Event Bus NetworkPolicy.'}
   $remaining=Select-String -Path ($files.FullName) -Pattern 'REGISTRY/|IMAGE_TAG|REPLACE_WITH_MANAGED_PLATFORM_CIDR|REPLACE_IN_ENVIRONMENT_OVERLAY|REPLACE_WITH_SECRET_MANAGER_REFERENCE_OR_VALUE|SET_BY_OPERATOR' -SimpleMatch:$false -ErrorAction SilentlyContinue
   if($remaining){throw 'Unresolved production deployment placeholders remain in generated manifests.'}
 }
 $applyPath=$gen
}else{$applyPath=$overlay}
Write-Host "[EMTAF] Starting $Environment ($ImageMode image mode) in $Namespace"
if($VerifySignatures){ if($ImageMode -ne 'cloud'){throw '-VerifySignatures requires -ImageMode cloud.'}; & (Join-Path $PSScriptRoot 'verify-images.ps1') -Registry $Registry -Tag $Tag }
if($Environment -in @('prod','staging') -and $ImageMode -eq 'cloud'){ if(-not (kubectl get clustersecretstore $SecretStoreName --ignore-not-found -o name)){ throw "ClusterSecretStore '$SecretStoreName' was not found. Install/configure External Secrets before deploying $Environment." } }
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f - | Out-Null
kubectl -n $Namespace delete job emtaf-migrations --ignore-not-found=true 2>$null | Out-Null
kubectl apply -k $applyPath
if($LASTEXITCODE -ne 0){throw "kubectl apply -k $applyPath failed."}
if($Environment -ne 'prod'){ foreach($deployment in @('postgres','redis','redpanda')){ kubectl -n $Namespace rollout status "deployment/$deployment" --timeout=240s } }
if(-not (kubectl -n $Namespace get job emtaf-migrations --ignore-not-found -o name)){throw "job/emtaf-migrations was not created by 'kubectl apply -k $applyPath'."}
kubectl -n $Namespace wait --for=condition=complete job/emtaf-migrations --timeout=300s
if($LASTEXITCODE -ne 0){throw 'emtaf-migrations job did not complete.'}
foreach($name in @('emtaf-tenant-service','hospital-service','school-service','college-service','hotel-service','realestate-service','hospital-site','school-site','college-site','hotel-site','realestate-site','skin-clinic-site','eecp-clinic-site','physiotherapy-site')){ if(kubectl -n $Namespace get deployment $name --ignore-not-found -o name){ kubectl -n $Namespace rollout status "deployment/$name" --timeout=180s } }
if(kubectl -n $Namespace get deployment emtaf-demo-wireframe --ignore-not-found -o name){kubectl -n $Namespace rollout status deployment/emtaf-demo-wireframe --timeout=180s}
Write-Host '[EMTAF] Started successfully.'
