[CmdletBinding()] param([ValidateSet('local','cloud')][string]$Mode='local',[string]$Registry='',[string]$Tag='dev',[switch]$Push)
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
& (Join-Path $root 'scripts\build.ps1') -Target college -Mode $Mode -Registry $Registry -Tag $Tag -Push:$Push
