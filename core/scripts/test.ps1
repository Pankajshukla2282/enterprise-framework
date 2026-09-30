$ErrorActionPreference='Stop'; $root=Resolve-Path (Join-Path $PSScriptRoot '..\..'); Push-Location $root; try { npm test --workspace=@emtaf/core } finally { Pop-Location }
