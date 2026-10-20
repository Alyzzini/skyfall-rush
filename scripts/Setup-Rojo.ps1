# Install the pinned official Rojo CLI in this project only. No admin rights needed.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolsPath = Join-Path $projectRoot '.tools'
$rojoPath = Join-Path $toolsPath 'rojo.exe'
if (Test-Path -LiteralPath $rojoPath) {
    & $rojoPath --version
    exit $LASTEXITCODE
}
New-Item -ItemType Directory -Force -Path $toolsPath | Out-Null
$archivePath = Join-Path $toolsPath 'rojo-7.7.1.zip'
Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-windows-x86_64.zip' -OutFile $archivePath
Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsPath -Force
& $rojoPath --version
