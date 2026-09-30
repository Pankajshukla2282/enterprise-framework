[CmdletBinding()]
param([ValidateSet('dev','staging','prod')][string]$Environment='dev',[ValidateSet('local','cloud')][string]$ImageMode='local',[string]$Registry='',[string]$Tag='dev',[string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
if(-not (Get-Command helm -ErrorAction SilentlyContinue)){throw 'helm is required.'}
$chart=Resolve-Path (Join-Path $PSScriptRoot '..\helm')
$repo='emtaf-hotel'
if($ImageMode -eq 'cloud'){ if([string]::IsNullOrWhiteSpace($Registry)){throw '-Registry is required in cloud mode'}; $imageRepo="$($Registry.TrimEnd('/'))/emtaf-hotel-service" } else { $imageRepo='emtaf-hotel-service' }
helm upgrade --install $repo $chart -n $Namespace --create-namespace --set image.repository=$imageRepo --set image.tag=$Tag --set imagePullPolicy=IfNotPresent
