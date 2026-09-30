[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Registry,[Parameter(Mandatory=$true)][string]$Tag)
$ErrorActionPreference='Stop'
if(-not(Get-Command cosign -ErrorAction SilentlyContinue)){throw 'cosign is required to verify signed production images.'}
$names=@('tenant-service','hospital-service','school-service','college-service','hotel-service','realestate-service','migrations')
foreach($n in $names){$image="$Registry/emtaf-$n`:$Tag"; Write-Host "Verifying $image"; cosign verify --certificate-identity-regexp 'https://github.com/.*/.github/workflows/.*' --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' $image | Out-Null}
Write-Host 'All release images have valid keyless signatures.'
