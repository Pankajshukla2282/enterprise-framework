[CmdletBinding()] param()
$ErrorActionPreference='Stop'
$root=Resolve-Path (Join-Path $PSScriptRoot '..\..')
npm run build --workspace=@emtaf/core
