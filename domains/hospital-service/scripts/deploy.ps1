[CmdletBinding()]
param([ValidateSet('dev','staging','prod')][string]$Environment='dev',[ValidateSet('local','cloud')][string]$ImageMode='local',[string]$Registry='',[string]$Tag='dev',[string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
if(-not (Get-Command helm -ErrorAction SilentlyContinue)){throw 'helm is required.'}
$chart=Resolve-Path (Join-Path $PSScriptRoot '..\helm')
$repo='emtaf-hospital'
if($ImageMode -eq 'cloud'){ if([string]::IsNullOrWhiteSpace($Registry)){throw '-Registry is required in cloud mode'}; $imageRepo="$($Registry.TrimEnd('/'))/emtaf-hospital-service" } else { $imageRepo='emtaf-hospital-service' }
helm upgrade --install $repo $chart -n $Namespace --create-namespace --set image.repository=$imageRepo --set image.tag=$Tag --set imagePullPolicy=IfNotPresent
