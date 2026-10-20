# NotePulse installer for Windows.
# Installs or replaces the latest release under %LOCALAPPDATA%\NotePulse, adds that folder to the
# user PATH once, and prints the two Claude Code lines that finish the setup.
#
# One-line install:  irm https://raw.githubusercontent.com/diegocesarmg/notepulse/main/install.ps1 | iex
#
# -ZipPath    Install from a local zip instead of the latest GitHub release (used by the tests).
# -InstallDir Target folder. Defaults to %LOCALAPPDATA%\NotePulse.
# -PathScope  User (default) updates the user PATH. Process only changes this session's PATH.
#             None leaves PATH alone. The tests use Process so they never touch the real user PATH.
param(
    [string]$ZipPath,
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'NotePulse'),
    [ValidateSet('User', 'Process', 'None')]
    [string]$PathScope = 'User'
)

$ErrorActionPreference = 'Stop'
$Repo = 'diegocesarmg/notepulse'

function Get-NormalizedPathEntry {
    param([string]$Entry)
    return $Entry.Trim().TrimEnd('\', '/').ToLowerInvariant()
}

function Merge-PathEntry {
    # Returns the PATH string with $Entry present exactly once. Other entries keep their order.
    param([AllowNull()][string]$Path, [string]$Entry)
    $target = Get-NormalizedPathEntry $Entry
    $kept = @()
    foreach ($item in @(([string]$Path) -split ';')) {
        if ([string]::IsNullOrWhiteSpace($item)) { continue }
        if ((Get-NormalizedPathEntry $item) -eq $target) { continue }
        $kept += $item
    }
    $kept += $Entry
    return ($kept -join ';')
}

function Add-InstallDirToPath {
    param([string]$Dir, [string]$Scope)
    if ($Scope -eq 'None') { return }
    if ($Scope -eq 'User') {
        $current = [Environment]::GetEnvironmentVariable('Path', 'User')
        [Environment]::SetEnvironmentVariable('Path', (Merge-PathEntry $current $Dir), 'User')
    }
    else {
        $env:Path = Merge-PathEntry $env:Path $Dir
    }
}

function Get-ReleaseZip {
    # Downloads the latest release asset whose name matches notepulse-<version>-win-x64.zip.
    param([string]$Destination)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = 'notepulse-install'; 'Accept' = 'application/vnd.github+json' }
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers
    $asset = @($release.assets | Where-Object { $_.name -like 'notepulse-*-win-x64.zip' }) | Select-Object -First 1
    if (-not $asset) { throw "No notepulse-*-win-x64.zip asset in the latest release of $Repo." }
    Write-Host "Downloading $($asset.name)..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $Destination -UseBasicParsing
    return $Destination
}

function Install-Payload {
    # Replaces $Dir with $Payload. The old folder is kept until the copy succeeds, then removed.
    param([string]$Payload, [string]$Dir)
    $backup = $null
    if (Test-Path -LiteralPath $Dir) {
        $backupName = (Split-Path -Leaf $Dir) + '.old-' + [guid]::NewGuid().ToString('N')
        try {
            Rename-Item -LiteralPath $Dir -NewName $backupName
        }
        catch {
            throw "Could not replace $Dir. Close any running NotePulse or Claude Code session and run the installer again."
        }
        $backup = Join-Path (Split-Path -Parent $Dir) $backupName
    }
    try {
        Copy-Item -LiteralPath $Payload -Destination $Dir -Recurse -Force
    }
    catch {
        if (Test-Path -LiteralPath $Dir) { Remove-Item -LiteralPath $Dir -Recurse -Force }
        if ($backup) { Rename-Item -LiteralPath $backup -NewName (Split-Path -Leaf $Dir) }
        throw
    }
    if ($backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
}

$workDir = Join-Path ([IO.Path]::GetTempPath()) ('notepulse-install-' + [guid]::NewGuid().ToString('N'))
$downloaded = $false
try {
    New-Item -ItemType Directory -Path $workDir | Out-Null

    if (-not $ZipPath) {
        $ZipPath = Get-ReleaseZip -Destination (Join-Path $workDir 'release.zip')
        $downloaded = $true
    }
    if (-not (Test-Path -LiteralPath $ZipPath)) { throw "Zip not found: $ZipPath" }

    $extracted = Join-Path $workDir 'extracted'
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $extracted -Force
    $exe = Get-ChildItem -LiteralPath $extracted -Recurse -Filter 'notepulse.exe' -File | Select-Object -First 1
    if (-not $exe) { throw 'The release zip has no notepulse.exe. Nothing was installed.' }

    Install-Payload -Payload $exe.Directory.FullName -Dir $InstallDir
    Add-InstallDirToPath -Dir $InstallDir -Scope $PathScope
}
finally {
    Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "NotePulse installed in $InstallDir"
Write-Host ''
Write-Host 'In Claude Code, run these two lines:'
Write-Host '  /plugin marketplace add diegocesarmg/notepulse'
Write-Host '  /plugin install notepulse@notepulse'
Write-Host ''
Write-Host 'Open a new terminal before using it, so the updated PATH is loaded.'
