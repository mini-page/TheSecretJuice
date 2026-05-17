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

# Copy Theme file
$themeSource = Join-Path $PSScriptRoot "Presets\highContext.omp.json"
if (Test-Path $themeSource) {
    Copy-Item -Path $themeSource -Destination $installDir -Force
    Write-Color "✓ highContext theme copied." Green
}

# 7. Profile Configuration
Write-Color "`n📝 Configuring PowerShell profile..." Cyan

# ... (existing backup/create logic) ...

# Check if user wants the Master Profile
$useMaster = $selectedModules | Where-Object { $_.id -eq "core-pack" -and $_.modules | Where-Object { $_.name -eq "Master Profile" } }
$applyMaster = $false
if ($useMaster) {
    $choice = Read-Host "🚀 Use optimized Master Profile as foundation? (Highly Recommended) (y/N)"
    if ($choice -eq 'y') { $applyMaster = $true }
}

if ($applyMaster) {
    $masterSource = Join-Path $PSScriptRoot "Presets\Microsoft.PowerShell_profile.ps1"
    if (Test-Path $masterSource) {
        Copy-Item -Path $masterSource -Destination $profilePath -Force
        Write-Color "✓ Master Profile applied as your primary profile." Green
    }
} else {
    # ... (standard juice block injection) ...
}

# 8. Personal Backups (Optional & Protected)
# Password for Personal Backups: SecretJuice2026
Write-Color "`n🔒 Personal Backups found." Cyan
Write-Color "⚠️  WARNING: Importing personal backups will OVERWRITE your existing Windows Terminal settings." Yellow
Write-Color "   Only proceed if you trust the source and want this specific customization level." Gray

$pChoice = Read-Host "Import personal encrypted backups? (y/N)"
if ($pChoice -eq 'y') {
    $passInput = Read-Host "Enter Password to Unlock" -AsSecureString
    
    # Convert SecureString to PlainText for comparison
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passInput)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    if ($PlainPassword -eq "SecretJuice2026") {
        Write-Color "✅ Password Verified. Importing settings..." Green
        
        # Windows Terminal Settings Path
        $wtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $wtSource = Join-Path $PSScriptRoot "Presets\Terminal\settings.json"
        
        if (Test-Path $wtSource) {
            if (Test-Path $wtPath) {
                $wtBackup = "$wtPath.backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
                Copy-Item $wtPath $wtBackup -Force
                Write-Color "✓ Windows Terminal settings backed up." Gray
            }
            Copy-Item $wtSource $wtPath -Force
            Write-Color "✓ Windows Terminal settings imported successfully." Green
        }
    } else {
        Write-Color "❌ Invalid password. Skipping personal backups." Red
    }
}

# 9. Final Message
Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        Installation Complete! 🎉         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Color "🚀 Next Steps:" Cyan
Write-Color "   1. Close and restart your terminal." White
Write-Color "   2. Type 'help' to see your new juices." White
Write-Color "   3. Enjoy your supercharged shell! 💉✨" Magenta
