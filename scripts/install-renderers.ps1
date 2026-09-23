# install-renderers.ps1 -- Windows helper for the viewer's OPTIONAL external renderers.
#
# Installs glow (markdown), delta (diffs), and bat (syntax) with WinGet when available.
# delta/bat can fall back to cargo; glow cannot because it is a Go program.
#
# These are runtime conveniences, not required dependencies. The viewer always falls back to
# plain text when a renderer is unavailable. This script is idempotent and never changes files in
# the repository.
$ErrorActionPreference = 'Continue'

function Have([string]$CommandName) {
    return $null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)
}

function Refresh-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($machine, $user) | Where-Object { $_ }
    if ($parts.Count -gt 0) {
        $env:Path = ($parts -join ';')
    }
}

$WingetIds = @{
    glow  = 'charmbracelet.glow'
    delta = 'dandavison.delta'
    bat   = 'sharkdp.bat'
}

$CargoPackages = @{
    delta = 'git-delta'
    bat   = 'bat'
}

function Install-WithWinget([string]$Tool) {
    if (-not (Have 'winget')) { return $false }

    $packageId = $WingetIds[$Tool]
    if (-not $packageId) { return $false }

    Write-Host "... trying WinGet: $packageId"
    & winget install --id $packageId --exact --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { return $false }

    # Portable WinGet packages may add their link directory to the user PATH during installation.
    # Refresh this PowerShell process so a successful install can be detected immediately.
    Refresh-ProcessPath
    return (Have $Tool)
}

function Install-WithCargo([string]$Tool) {
    if (-not (Have 'cargo')) { return $false }

    $package = $CargoPackages[$Tool]
    if (-not $package) { return $false }

    Write-Host "... trying cargo install $package"
    & cargo install $package
    if ($LASTEXITCODE -ne 0) { return $false }

    Refresh-ProcessPath
    return (Have $Tool)
}

function Install-One([string]$Tool) {
    if (Have $Tool) {
        $command = (Get-Command $Tool -ErrorAction SilentlyContinue).Source
        Write-Host "[ok] $Tool already installed ($command)"
        return $true
    }

    if (Install-WithWinget $Tool) {
        Write-Host "[ok] installed $Tool with WinGet"
        return $true
    }

    if (($Tool -eq 'delta' -or $Tool -eq 'bat') -and (Install-WithCargo $Tool)) {
        Write-Host "[ok] installed $Tool with cargo"
        return $true
    }

    Write-Host "[missing] could not put '$Tool' on PATH."
    switch ($Tool) {
        'glow'  { Write-Host '          https://github.com/charmbracelet/glow#installation' }
        'delta' { Write-Host '          https://github.com/dandavison/delta#installation' }
        'bat'   { Write-Host '          https://github.com/sharkdp/bat#installation' }
    }
    return $false
}

Write-Host 'herdr-file-viewer - optional renderers (Windows)'
if (Have 'winget') {
    Write-Host 'package manager: WinGet'
} elseif (Have 'cargo') {
    Write-Host 'WinGet not found; cargo fallback is available for delta/bat'
} else {
    Write-Host 'WinGet/cargo not found; missing renderers will need manual installation'
}
Write-Host ''

$ok = $true
foreach ($tool in @('glow', 'delta', 'bat')) {
    if (-not (Install-One $tool)) { $ok = $false }
}

Write-Host ''
if ($ok) {
    Write-Host 'All renderers are available - markdown, diffs, and code will be styled.'
} else {
    Write-Host 'Some renderers are missing; the viewer still works with plain-text fallback.'
}

# Match the Unix helper: renderer installation is best-effort and never makes plugin setup fail.
exit 0
