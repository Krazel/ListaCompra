param(
  [Parameter(Mandatory=$true)][string]$Repo
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Gh = Join-Path $Root "..\gh.bat"
$Artifact = Join-Path $Root "artifact"
$Old = Join-Path $Artifact "old"
New-Item -ItemType Directory -Force -Path $Artifact, $Old | Out-Null

$sha = git -C $Root rev-parse HEAD
Write-Host "Buscando workflow para commit $sha en $Repo..."

for ($i = 0; $i -lt 60; $i++) {
  $runsJson = & $Gh run list --repo $Repo --commit $sha --json databaseId,status,conclusion,url --limit 1
  $runs = $runsJson | ConvertFrom-Json
  if ($runs.Count -gt 0) {
    $run = $runs[0]
    if ($run.status -eq "completed") {
      if ($run.conclusion -ne "success") {
        Write-Host "Build fallida: $($run.url)"
        exit 1
      }
      $Download = Join-Path $Artifact "download"
      if (Test-Path $Download) { Remove-Item -LiteralPath $Download -Recurse -Force }
      New-Item -ItemType Directory -Force -Path $Download | Out-Null
      & $Gh run download $run.databaseId --repo $Repo --dir $Download

      $newIpa = Get-ChildItem $Download -Recurse -File -Filter "*.ipa" | Select-Object -First 1
      if ($null -eq $newIpa) {
        Write-Host "No se encontro IPA en los artifacts descargados"
        exit 1
      }

      Get-ChildItem $Artifact -File -Filter "*.ipa" | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination (Join-Path $Old $_.Name) -Force
      }
      Copy-Item -LiteralPath $newIpa.FullName -Destination (Join-Path $Artifact $newIpa.Name) -Force
      Remove-Item -LiteralPath $Download -Recurse -Force
      Write-Host "IPA descargada en $(Join-Path $Artifact $newIpa.Name)"
      exit 0
    }
    Write-Host "Workflow en estado $($run.status). Esperando..."
  }
  Start-Sleep -Seconds 15
}

Write-Host "No se encontro una build terminada para $sha"
exit 1
