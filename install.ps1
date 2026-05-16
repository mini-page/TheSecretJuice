# install.ps1
# TheSecretJuice Interactive Installer
# Part of TheSecretJuice by mini-page

# 1. Initialization & UI Helpers
function Write-Color {
    param([string]$Message, [string]$Color = 'White', [switch]$NoNewLine)
    if ($NoNewLine) { Write-Host -ForegroundColor $Color -NoNewline $Message }
    else { Write-Host -ForegroundColor $Color $Message }
}

function Show-JuiceBanner {
    Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║     TheSecretJuice Installer v2.0       ║" -ForegroundColor Magenta
    Write-Host "║   Interactive CLI Steroids Wizard       ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Magenta
}

Show-JuiceBanner

# 2. Setup Paths
$isWindows = $IsWindows -or $env:OS -match "Windows"
if ($isWindows) {
    $installDir = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"
    $profilePath = $PROFILE
} else {
    $installDir = "$HOME/.config/powershell/Scripts/TheSecretJuice"
    $profilePath = "$HOME/.config/powershell/profile.ps1"
}

# 3. Load Modules Data
$modulesJsonPath = Join-Path $PSScriptRoot "docs\assets\data\modules.json"
if (-not (Test-Path $modulesJsonPath)) {
    # Fallback if running via IEX without local clone context (though IEX usually downloads the repo first)
    Write-Color "⚠️  modules.json not found locally. Using default set." Yellow
    $modules = @() # In a real script, we might fetch from GitHub URL
} else {
    $modules = Get-Content $modulesJsonPath | ConvertFrom-Json
}

# 4. Interactive Selection
Write-Color "💉 Select the Steroids you want to inject:" Cyan
$selectedModules = @()
$counter = 1

foreach ($mod in $modules) {
    $status = "[ ]"
    Write-Color "   $counter. $status $($mod.name)" White -NoNewLine
    Write-Color " - $($mod.description)" Gray
    $counter++
}

Write-Color "`nEnter the numbers of the modules you want (e.g. 1,2,5) or 'all':" Cyan
$inputChoice = Read-Host "Choice"

if ($inputChoice -eq 'all') {
    $selectedModules = $modules
} else {
    $indexes = $inputChoice -split ',' | ForEach-Object { $_.Trim() }
    foreach ($idx in $indexes) {
        if ($idx -match '^\d+$') {
            $val = [int]$idx - 1
            if ($val -ge 0 -and $val -lt $modules.Count) {
                $selectedModules += $modules[$val]
            }
        }
    }
}

if ($selectedModules.Count -eq 0) {
    Write-Color "❌ No modules selected. Aborting." Red
    return
}

# 5. Dependency Check & Manual
Write-Color "`n🔍 Checking dependencies for selected tools..." Cyan
$missingDeps = @()

foreach ($mod in $selectedModules) {
    if ($mod.dependencies) {
        foreach ($dep in $mod.dependencies) {
            if (-not (Get-Command $dep.name -ErrorAction SilentlyContinue)) {
                if (-not ($missingDeps | Where-Object { $_.name -eq $dep.name })) {
                    $missingDeps += $dep
                }
            }
        }
    }
}

if ($missingDeps.Count -gt 0) {
    Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║       DEPENDENCY MANUAL REQUIRED         ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Yellow
    Write-Color "The following tools are missing and required for your selection:" Yellow
    
    foreach ($dep in $missingDeps) {
        Write-Color "   • $($dep.name)" White -NoNewLine
        Write-Color " -> Download from: " Gray -NoNewline
        Write-Color "$($dep.url)" Cyan
    }
    
    Write-Color "`n⚠️  Please download and install these tools first, then restart the terminal and run this installer again." Yellow
    $proceed = Read-Host "Proceed anyway? (y/N)"
    if ($proceed -ne 'y') {
        Write-Color "Aborting installation to let you install dependencies." Gray
        return
    }
}

# 6. Physical Installation (Copying Files)
Write-Color "`n📥 Installing files to $installDir..." Cyan
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Copy Steroids folder contents
$steroidsSource = Join-Path $PSScriptRoot "Steroids"
if (Test-Path $steroidsSource) {
    Copy-Item -Path "$steroidsSource\*" -Destination $installDir -Recurse -Force
    Write-Color "✓ Steroids folder copied." Green
}

# 7. Profile Configuration
Write-Color "`n📝 Configuring PowerShell profile..." Cyan

# Create profile if missing
if (-not (Test-Path $profilePath)) {
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
# Remove old Juice block
$profileContent = $profileContent -replace "(?s)# --- TheSecretJuice Start ---.*?# --- TheSecretJuice End ---", ""
$profileContent = $profileContent.Trim()

$juiceBlock = "`n# --- TheSecretJuice Start ---`n"
$juiceBlock += "`$juicePath = `"$installDir`"`n"
$juiceBlock += ". `"`$juicePath\Core\Juice-Helpers.ps1`"`n" # Always load helpers first

foreach ($mod in $selectedModules) {
    if ($mod.isPack) {
        $juiceBlock += "# $($mod.name) Pack`n"
        foreach ($submod in $mod.modules) {
            $juiceBlock += ". `"`$juicePath\$($mod.id -replace '-pack', '')\$($submod.path)`"`n"
        }
    } else {
        $juiceBlock += ". `"`$juicePath\$(Split-Path $mod.path -Leaf)`"`n"
    }
}
$juiceBlock += "# --- TheSecretJuice End ---`n"

$newProfileContent = $profileContent + $juiceBlock
Set-Content -Path $profilePath -Value $newProfileContent
Write-Color "✓ Profile updated successfully." Green

# 8. Final Message
Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        Installation Complete! 🎉         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Color "🚀 Next Steps:" Cyan
Write-Color "   1. Close and restart your terminal." White
Write-Color "   2. Type 'help' to see your new juices." White
Write-Color "   3. Enjoy your supercharged shell! 💉✨" Magenta
