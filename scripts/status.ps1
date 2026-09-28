[CmdletBinding()]
param([string]$Namespace='emtaf')
$ErrorActionPreference='Stop'
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { throw 'kubectl is required. Install it and ensure it is on PATH.' }
kubectl -n $Namespace get deploy,svc,job,pods -o wide
