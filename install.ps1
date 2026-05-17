# install.ps1
# TheSecretJuice Interactive Installer v3.0
# Optimized for Reliability and Layman Simplicity.

# 1. Initialization & UI Helpers
function Write-Color {
    param([string]$Message, [string]$Color = 'White', [switch]$NoNewLine)
    $validColors = [enum]::GetNames([System.ConsoleColor])
    $safeColor = if ($validColors -contains $Color) { $Color } else { 'White' }
    if ($NoNewLine) { Write-Host -ForegroundColor $safeColor -NoNewline $Message }
    else { Write-Host -ForegroundColor $safeColor $Message }
}

function Show-JuiceBanner {
    Write-Host "`n==========================================" -ForegroundColor Magenta
    Write-Host "     TheSecretJuice Installer v3.0       " -ForegroundColor Magenta
    Write-Host "   Interactive CLI Steroids Wizard       " -ForegroundColor Magenta
    Write-Host "==========================================`n" -ForegroundColor Magenta
}

Show-JuiceBanner

# 2. Setup Paths
$isWindows = $IsWindows -or ($env:OS -match "Windows")
if ($isWindows) {
    $installDir = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"
    $profilePath = $PROFILE
} else {
    $installDir = "$HOME/.config/powershell/Scripts/TheSecretJuice"
    $profilePath = "$HOME/.config/powershell/profile.ps1"
}

# 3. Load Modules Data
$modulesJsonPath = Join-Path $PSScriptRoot "docs\assets\data\modules.json"
$modules = @()
if (Test-Path $modulesJsonPath) {
    $modules = Get-Content $modulesJsonPath | ConvertFrom-Json
} else {
    Write-Color "modules.json not found locally. Aborting." Yellow
    return
}

# 4. Interactive Selection
Write-Color "Select the Steroids you want to inject:" Cyan
$selectedModules = @()
$counter = 1
foreach ($mod in $modules) {
    Write-Color "   $counter. [ ] $($mod.name)" White -NoNewLine
    Write-Color " - $($mod.description)" Gray
    $counter++
}

Write-Color "`nEnter numbers (e.g. 1,2,5) or 'all':" Cyan
$inputChoice = Read-Host "Choice"
if ($inputChoice -eq 'all') {
    $selectedModules = $modules
} else {
    $indexes = $inputChoice -split ',' | ForEach-Object { $_.Trim() }
    foreach ($idx in $indexes) {
        if ($idx -match '^\d+$') {
            $val = [int]$idx - 1
            if ($val -ge 0 -and $val -lt $modules.Count) { $selectedModules += $modules[$val] }
        }
    }
}

if ($selectedModules.Count -eq 0) {
    Write-Color "No modules selected. Aborting." Red
    return
}

# 5. Dependency Check
Write-Color "`nChecking dependencies..." Cyan
$missingDeps = @()
foreach ($mod in $selectedModules) {
    if ($mod.dependencies) {
        foreach ($dep in $mod.dependencies) {
            if (-not (Get-Command $dep.name -ErrorAction SilentlyContinue)) {
                if (-not ($missingDeps | Where-Object { $_.name -eq $dep.name })) { $missingDeps += $dep }
            }
        }
    }
}

if ($missingDeps.Count -gt 0) {
    Write-Color "`nMissing Requirements:" Yellow
    foreach ($dep in $missingDeps) { Write-Color "   * $($dep.name) -> $($dep.url)" Cyan }
    $proceed = Read-Host "`nProceed anyway? (y/N)"
    if ($proceed -ne 'y') { return }
}

# 6. Physical Installation
Write-Color "`nDeploying v3.0 Core & Modules..." Cyan
try {
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    $source = Join-Path $PSScriptRoot "Steroids"
    if (Test-Path $source) {
        Copy-Item -Path "$source\*" -Destination $installDir -Recurse -Force
        Write-Color "Logic modules deployed." Green
    }
    $presets = Join-Path $PSScriptRoot "Presets"
    if (Test-Path $presets) {
        Copy-Item -Path "$presets\*" -Destination $installDir -Recurse -Force
        Write-Color "Presets & Themes deployed." Green
    }
} catch {
    Write-Color "Copy failed: $($_.Exception.Message)" Red
    return
}

# 7. Profile Configuration
Write-Color "`nConfiguring profile..." Cyan
if (Test-Path $profilePath) {
    $bak = "$profilePath.backup-$(Get-Date -Format 'HHmmss')"
    Copy-Item $profilePath $bak -Force
    Write-Color "Profile backed up." Gray
}

$useMaster = $selectedModules | Where-Object { $_.id -eq "v3-core" }
if ($useMaster) {
    $choice = Read-Host "Use v3 Master Profile foundation? (y/N)"
    if ($choice -eq 'y') {
        $master = Join-Path $installDir "Microsoft.PowerShell_profile.ps1"
        if (Test-Path $master) {
            $content = Get-Content $master -Raw
            $content = $content -replace '\$JuiceRoot = .*', "`$JuiceRoot = `"$installDir`""
            Set-Content -Path $profilePath -Value $content -Force
            Write-Color "Master Profile v3.0 Active." Green
        }
    }
}

# 8. Personal Backups (Terminal Settings)
$wtSource = Join-Path $installDir "Terminal\settings.json"
if (Test-Path $wtSource) {
    Write-Color "`nPersonal Terminal Settings found." Cyan
    $pChoice = Read-Host "Apply premium terminal visuals? (y/N)"
    if ($pChoice -eq 'y') {
        $pass = Read-Host "Password (SecretJuice2026)" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if ($plain -eq "SecretJuice2026") {
            $wtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            Copy-Item $wtSource $wtPath -Force
            Write-Color "Terminal visuals applied." Green
        } else {
            Write-Color "Invalid password." Red
        }
    }
}

Write-Color "`nInstallation Complete! Close and restart your terminal." Green
