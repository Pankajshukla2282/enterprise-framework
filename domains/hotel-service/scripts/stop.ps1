[CmdletBinding()] param([string]$Namespace='emtaf',[switch]$PurgeData)
$ErrorActionPreference='Stop'
if($PurgeData){ kubectl -n $Namespace delete deployment hotel-service --ignore-not-found; kubectl -n $Namespace delete service hotel-service --ignore-not-found; Write-Warning 'Service resources removed. Shared platform data is retained unless root stop.ps1 -PurgeData is explicitly used.' } else { kubectl -n $Namespace scale deployment/hotel-service --replicas=0 }
