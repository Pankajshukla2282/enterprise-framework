[CmdletBinding()] param([string]$Namespace='emtaf',[switch]$PurgeData)
$ErrorActionPreference='Stop'
if($PurgeData){ kubectl -n $Namespace delete deployment hospital-service --ignore-not-found; kubectl -n $Namespace delete service hospital-service --ignore-not-found; Write-Warning 'Service resources removed. Shared platform data is retained unless root stop.ps1 -PurgeData is explicitly used.' } else { kubectl -n $Namespace scale deployment/hospital-service --replicas=0 }
