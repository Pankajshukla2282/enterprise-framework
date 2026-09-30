[CmdletBinding()] param([string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\status.ps1')
Write-Host "`nHospital deployment:"
kubectl -n $Namespace get deployment hospital-service -o wide
kubectl -n $Namespace get pods -l app=hospital-service -o wide
