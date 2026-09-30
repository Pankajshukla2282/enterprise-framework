$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..'); & (Join-Path $root 'scripts\status.ps1'); kubectl -n emtaf get deployment emtaf-tenant-service -o wide
