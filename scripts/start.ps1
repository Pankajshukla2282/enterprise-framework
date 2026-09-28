[CmdletBinding()]
param(
  [ValidateSet('dev','staging','prod')][string]$Environment='dev',
  [ValidateSet('local','cloud')][string]$ImageMode='local',
  [string]$Registry='',
  [string]$Tag='dev',
  [string]$Namespace='emtaf'
)
$ErrorActionPreference='Stop'
$Root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
function Require([string]$n){if(-not(Get-Command $n -ErrorAction SilentlyContinue)){throw "$n is required."}}
Require kubectl
$overlay=Join-Path $Root "infra\kubernetes\overlays\$Environment"
if($ImageMode -eq 'cloud'){
 if([string]::IsNullOrWhiteSpace($Registry)){throw 'Cloud image mode requires -Registry, e.g. -Registry ghcr.io/your-org'}
 $gen=Join-Path $Root ('infra\kubernetes\overlays\.generated\'+$Environment)
 New-Item -ItemType Directory -Force -Path $gen | Out-Null
 $template=Get-Content (Join-Path $Root 'infra\kubernetes\overlays\cloud\kustomization.template.yaml') -Raw
 $template=$template.Replace('__EMTAF_REGISTRY__',$Registry.TrimEnd('/')).Replace('__EMTAF_TAG__',$Tag)
 $template=$template.Replace('__ENV__',$Environment)
 $template | Set-Content (Join-Path $gen 'kustomization.yaml') -Encoding utf8
 # The generated overlay inherits the selected environment.
 (Get-Content (Join-Path $gen 'kustomization.yaml') -Raw).Replace('- ../../base',"- ../../$Environment") | Set-Content (Join-Path $gen 'kustomization.yaml') -Encoding utf8
 $applyPath=$gen
}else{$applyPath=$overlay}
Write-Host "[EMTAF] Starting $Environment ($ImageMode image mode) in $Namespace"
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f - | Out-Null
kubectl -n $Namespace delete job emtaf-migrations --ignore-not-found=true 2>$null | Out-Null
kubectl apply -k $applyPath
foreach($deployment in @('postgres','redis','redpanda')){ kubectl -n $Namespace rollout status "deployment/$deployment" --timeout=240s }
kubectl -n $Namespace wait --for=condition=complete job/emtaf-migrations --timeout=300s
foreach($service in @('tenant','hospital','school','college','hotel','realestate')){ $name="emtaf-$service-service"; if(kubectl -n $Namespace get deployment $name --ignore-not-found -o name){ kubectl -n $Namespace rollout status "deployment/$name" --timeout=180s } }
if(kubectl -n $Namespace get deployment emtaf-demo-wireframe --ignore-not-found -o name){kubectl -n $Namespace rollout status deployment/emtaf-demo-wireframe --timeout=180s}
Write-Host '[EMTAF] Started successfully.'
