[CmdletBinding()]
param(
  [int]$SitePort = 3008,
  [int]$ApiPort = 8080,
  [string]$Service = 'hospital-service',
  [string]$Namespace = 'emtaf'
)
$ErrorActionPreference = 'Stop'
$SiteDir = 'physiotherapy-site'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
foreach ($n in @('kubectl','node')) { if (-not (Get-Command $n -ErrorAction SilentlyContinue)) { throw "$n is required." } }

$pf = Start-Job -ScriptBlock { param($ns,$svc,$port) & kubectl -n $ns port-forward "svc/$svc" "$port`:80" } -ArgumentList $Namespace,$Service,$ApiPort
try {
  $deadline = (Get-Date).AddSeconds(60)
  while ($true) {
    try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('127.0.0.1',$ApiPort); $c.Close(); break }
    catch { if ((Get-Date) -gt $deadline) { throw "Timed out waiting for port-forward $Service -> localhost:$ApiPort" }; Start-Sleep -Milliseconds 500 }
  }
  $env:API_BASE = "http://localhost:$ApiPort"
  $env:PORT = "$SitePort"
  Write-Host "[EMTAF] physiotherapy-site -> http://localhost:$SitePort (API $Service via localhost:$ApiPort)"
  Write-Host "[EMTAF] Mint a token, then paste it into the site Connect box:"
  Write-Host '  $b64 = kubectl -n emtaf get secret emtaf-platform-secrets -o jsonpath="{.data.JWT_SECRET}"'
  Write-Host '  $env:JWT_SECRET = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))'
  Write-Host '  npm run token --prefix physiotherapy-site   # hospital.admin@demo.local / demo-hospital'
  & node (Join-Path $Root "$SiteDir\server.mjs")
}
finally { Remove-Job -Force $pf -ErrorAction SilentlyContinue }
