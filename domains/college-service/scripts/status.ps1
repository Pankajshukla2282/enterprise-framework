[CmdletBinding()] param([string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\status.ps1')
Write-Host "`nCollege deployment:"
kubectl -n $Namespace get deployment college-service -o wide
kubectl -n $Namespace get pods -l app=college-service -o wide
