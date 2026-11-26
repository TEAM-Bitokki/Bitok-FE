# Builds the release APK and copies it as BitOK-v<version>.apk.
# Usage (from the project root): .\scripts\build_apk.ps1
# Flutter always names its output app-release.apk, so the rename happens after the build.

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

flutter build apk --release --dart-define-from-file=dart_defines.json
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$versionLine = Select-String -Path pubspec.yaml -Pattern '^version:\s*([^+\s]+)' | Select-Object -First 1
$version = $versionLine.Matches[0].Groups[1].Value

$outDir = 'build\app\outputs\flutter-apk'
$target = Join-Path $outDir "BitOK-v$version.apk"
Copy-Item (Join-Path $outDir 'app-release.apk') $target -Force

Write-Host "APK ready: $target"
