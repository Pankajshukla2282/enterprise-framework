[CmdletBinding()] param([string]$Namespace='emtaf',[switch]$PurgeData)
$ErrorActionPreference='Stop'
if($PurgeData){ kubectl -n $Namespace delete deployment realestate-service --ignore-not-found; kubectl -n $Namespace delete service realestate-service --ignore-not-found; Write-Warning 'Service resources removed. Shared platform data is retained unless root stop.ps1 -PurgeData is explicitly used.' } else { kubectl -n $Namespace scale deployment/realestate-service --replicas=0 }
