[CmdletBinding()]
param(
  [ValidateSet('check','login','push','build-and-push','mirror-platform')][string]$Action='check',
  [string]$Registry=$env:EMTAF_REGISTRY,
  [string]$Username=$env:EMTAF_REGISTRY_USER,
  [string]$Password=$env:EMTAF_REGISTRY_PASSWORD,
  [string]$Tag=$(if($env:EMTAF_IMAGE_TAG){$env:EMTAF_IMAGE_TAG}else{'dev'})
)
$ErrorActionPreference='Stop'
if($Action -ne 'check' -and [string]::IsNullOrWhiteSpace($Registry)){throw 'Registry is required. Set EMTAF_REGISTRY or use -Registry.'}
if(-not (Get-Command docker -ErrorAction SilentlyContinue)){throw 'Docker is required.'}
if($Action -eq 'check'){ Write-Host 'Local mode: no registry login is required.'; Write-Host 'Cloud mode: set EMTAF_REGISTRY and run docker login to that registry.'; exit 0 }
if($Action -eq 'login'){
 if([string]::IsNullOrWhiteSpace($Username)){ docker login $Registry }
 elseif([string]::IsNullOrWhiteSpace($Password)){ throw 'When -Username is supplied non-interactively, provide -Password via a secure mechanism or use docker login interactively.' }
 else { $Password | docker login $Registry --username $Username --password-stdin }
 exit 0
}
if($Action -eq 'mirror-platform'){
 if([string]::IsNullOrWhiteSpace($Registry)){throw 'Registry is required.'}
 $platform=@{'postgres:16-alpine'='emtaf-postgres:16-alpine';'redis:7-alpine'='emtaf-redis:7-alpine';'docker.redpanda.com/redpandadata/redpanda:v24.3.5'='emtaf-redpanda:v24.3.5'}
 foreach($src in $platform.Keys){ docker pull $src; docker tag $src "$Registry/$($platform[$src])"; docker push "$Registry/$($platform[$src])" }
 exit 0
}
if($Action -eq 'push'){
 & "$PSScriptRoot/build.ps1" -Target all -Mode cloud -Registry $Registry -Tag $Tag -Push
 exit $LASTEXITCODE
}
if($Action -eq 'build-and-push'){
 & "$PSScriptRoot/build.ps1" -Target all -Mode cloud -Registry $Registry -Tag $Tag -Push
 exit $LASTEXITCODE
}
