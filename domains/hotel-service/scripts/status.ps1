[CmdletBinding()] param([string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\status.ps1')
Write-Host "`nHotel deployment:"
kubectl -n $Namespace get deployment hotel-service -o wide
kubectl -n $Namespace get pods -l app=hotel-service -o wide
