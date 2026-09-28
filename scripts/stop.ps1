[CmdletBinding()]
param(
  [ValidateSet('dev','staging','prod')][string]$Environment = 'dev',
  [string]$Namespace = 'emtaf',
  [switch]$PurgeData
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { throw 'kubectl is required. Install it and ensure it is on PATH.' }
$Overlay = Join-Path $Root "infra\kubernetes\overlays\$Environment"
Write-Host "[EMTAF] Tearing down $Environment..."
kubectl delete -k $Overlay --ignore-not-found=true 2>$null | Out-Null
kubectl -n $Namespace delete job emtaf-migrations --ignore-not-found=true 2>$null | Out-Null
if ($PurgeData) {
  kubectl delete namespace $Namespace --ignore-not-found=true
  Write-Host '[EMTAF] Namespace and persistent data purged.'
} else {
  Write-Host '[EMTAF] Workloads removed; namespace and data retained.'
  Write-Host "Use: .\scripts\stop.ps1 -Environment $Environment -PurgeData"
}
