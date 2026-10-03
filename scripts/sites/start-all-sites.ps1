[CmdletBinding()]
param([string]$Namespace = 'emtaf')
$ErrorActionPreference = 'Stop'
foreach ($n in @('kubectl','node')) { if (-not (Get-Command $n -ErrorAction SilentlyContinue)) { throw "$n is required." } }
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$forwards = @(
  @{ Svc = 'hospital-service'; Port = 8081 },
  @{ Svc = 'school-service'; Port = 8082 },
  @{ Svc = 'college-service'; Port = 8083 },
  @{ Svc = 'hotel-service'; Port = 8084 },
  @{ Svc = 'realestate-service'; Port = 8085 }
)
$sites = @(
  @{ Dir = 'hospital-site'; SitePort = 3001; ApiPort = 8081 },
  @{ Dir = 'school-site'; SitePort = 3003; ApiPort = 8082 },
  @{ Dir = 'college-site'; SitePort = 3004; ApiPort = 8083 },
  @{ Dir = 'hotel-site'; SitePort = 3005; ApiPort = 8084 },
  @{ Dir = 'realestate-site'; SitePort = 3002; ApiPort = 8085 },
  @{ Dir = 'skin-clinic-site'; SitePort = 3006; ApiPort = 8081 },
  @{ Dir = 'eecp-clinic-site'; SitePort = 3007; ApiPort = 8081 },
  @{ Dir = 'physiotherapy-site'; SitePort = 3008; ApiPort = 8081 }
)

$jobs = @()
try {
  foreach ($f in $forwards) {
    $jobs += Start-Job -ScriptBlock { param($ns,$svc,$port) & kubectl -n $ns port-forward "svc/$svc" "$port`:80" } -ArgumentList $Namespace,$f.Svc,$f.Port
  }
  foreach ($s in $sites) {
    $deadline = (Get-Date).AddSeconds(60)
    while ($true) {
      try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('127.0.0.1',$s.ApiPort); $c.Close(); break }
      catch { if ((Get-Date) -gt $deadline) { throw "Timed out waiting for localhost:$($s.ApiPort)" }; Start-Sleep -Milliseconds 500 }
    }
    $jobs += Start-Job -ScriptBlock {
      param($root,$dir,$sport,$aport)
      $env:API_BASE = "http://localhost:$aport"; $env:PORT = "$sport"
      & node (Join-Path $root "$dir\server.mjs")
    } -ArgumentList $Root,$s.Dir,$s.SitePort,$s.ApiPort
    Write-Host "[EMTAF] $($s.Dir) -> http://localhost:$($s.SitePort)"
  }
  Write-Host '[EMTAF] All sites running. Mint tokens with $env:JWT_SECRET from emtaf-platform-secrets, then Connect in each site. Ctrl+C stops.'
  Wait-Job $jobs | Out-Null
}
finally { Remove-Job -Force $jobs -ErrorAction SilentlyContinue }
