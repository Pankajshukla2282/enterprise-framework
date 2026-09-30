[CmdletBinding()] param([string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\status.ps1')
Write-Host "`nReal Estate deployment:"
kubectl -n $Namespace get deployment realestate-service -o wide
kubectl -n $Namespace get pods -l app=realestate-service -o wide
