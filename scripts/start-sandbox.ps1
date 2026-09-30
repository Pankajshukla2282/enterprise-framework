param([switch]$Seed)
$ErrorActionPreference='Stop'
kubectl apply -k infra/kubernetes/overlays/sandbox
kubectl rollout status deployment/hospital-service -n emtaf-training --timeout=180s
kubectl rollout status deployment/demo-wireframe -n emtaf-training --timeout=180s
if($Seed){ & $PSScriptRoot/seed.ps1 -Environment sandbox }
