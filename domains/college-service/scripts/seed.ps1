[CmdletBinding()] param([ValidateSet('dev','staging','prod')][string]$Environment='dev')
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\seed.ps1') -Environment $Environment
