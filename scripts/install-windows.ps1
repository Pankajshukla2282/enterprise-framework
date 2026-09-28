[CmdletBinding()]
param([switch]$InstallOptionalTools)
$ErrorActionPreference='Stop'
Write-Host 'EMTAF Windows prerequisite check'
$tools = @('node','npm','kubectl','helm')
foreach ($tool in $tools) {
  $cmd = Get-Command $tool -ErrorAction SilentlyContinue
  if ($cmd) { Write-Host "[OK] $tool -> $($cmd.Source)" } else { Write-Warning "$tool is missing" }
}
if (Get-Command docker -ErrorAction SilentlyContinue) { Write-Host '[OK] docker available' } else { Write-Warning 'docker is missing (needed for local image builds; not required by kubectl itself)' }
if ($InstallOptionalTools -and (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host 'Installing missing tools through winget...'
  winget install --id OpenJS.NodeJS.LTS --exact --accept-source-agreements --accept-package-agreements
  winget install --id Kubernetes.kubectl --exact --accept-source-agreements --accept-package-agreements
  winget install --id Helm.Helm --exact --accept-source-agreements --accept-package-agreements
  Write-Host 'Restart PowerShell after installation so PATH changes are loaded.'
} elseif ($InstallOptionalTools) {
  Write-Warning 'winget is not available. Install Node.js 22+, kubectl and Helm manually.'
}
