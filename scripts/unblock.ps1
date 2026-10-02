# Unblock all repo files after extracting a release zip (strips Mark of the Web).
param([string]$Root = (Split-Path -Parent $PSScriptRoot))
Get-ChildItem -Path $Root -Recurse -File | Unblock-File
Write-Host "Unblocked all files under $Root"
