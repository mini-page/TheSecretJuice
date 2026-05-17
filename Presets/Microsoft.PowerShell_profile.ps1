# ============================================
# The Secret Juice - Master Profile (v3.0)
# Clean • Fast • Modular • Intelligent
# ============================================

# ---------- Timer ----------
$__ProfileStart = Get-Date

# ---------- Minimal Mode ----------
# Launch minimal shell: $env:PWSH_MINIMAL=1; pwsh
if ($env:PWSH_MINIMAL -eq "1") { return }

# ---------- Silent Boot ----------
$__OldProgressPreference = $ProgressPreference
$ProgressPreference    = 'SilentlyContinue'

# ---------- Debug Switch ----------
$global:PROFILE_DEBUG = $false

function __LogOk($msg)  { if ($global:PROFILE_DEBUG) { Write-Host "✅ $msg" -ForegroundColor Green } }
function __LogWarn($msg){ if ($global:PROFILE_DEBUG) { Write-Host "⚠️ $msg" -ForegroundColor Yellow } }

# ---------- Utility: Safe Import ----------
function Import-ModuleSafe {
    param([Parameter(Mandatory)][string]$Name)
    try {
        Import-Module $Name -ErrorAction Stop | Out-Null
        __LogOk "$Name loaded"
        return $true
    } catch {
        __LogWarn "$Name not loaded"
        return $false
    }
}

# ---------- Utility: Cache Discovery ----------
function Get-CachedFileList {
    param([string]$Folder, [string]$Filter, [string]$CacheFile)
    if (-not (Test-Path $Folder)) { return @() }
    
    # Simple discovery for now; v3 will use a real registry
    return Get-ChildItem -Path $Folder -Filter $Filter -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
}

# ============================================
# Core Initialization
# ============================================

# Define project root
$JuiceRoot = "$HOME\Documents\PowerShell\Scripts\TheSecretJuice"
if (-not (Test-Path $JuiceRoot)) {
    # Fallback to current script location if running from repo
    $JuiceRoot = Split-Path $PSScriptRoot -Parent
}

# 1. Load v3 Core (Critical)
$JuiceCorePath = Join-Path $JuiceRoot "Steroids\Core\Juice-Core.ps1"
$HelpersPath   = Join-Path $JuiceRoot "Steroids\Core\Juice-Helpers.ps1"

if (Test-Path $HelpersPath)   { . $HelpersPath }
if (Test-Path $JuiceCorePath) { . $JuiceCorePath }

# 2. Oh-My-Posh (Theme)
$ThemePath = Join-Path $JuiceRoot "Presets\highContext.omp.json"
if (Test-Path $ThemePath) {
    try {
        oh-my-posh init pwsh --config $ThemePath | Invoke-Expression
        __LogOk "Theme loaded: highContext"
    } catch { }
}

# 3. Zoxide (Navigation)
try {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    __LogOk "zoxide initialized"
} catch { }

# ============================================
# Modules & Steroids Auto-Load
# ============================================

$modules = @('Terminal-Icons', 'posh-git', 'PSFzf', 'PSReadLine')
foreach ($m in $modules) { Import-ModuleSafe $m | Out-Null }

# Load Steroids (Recursive Discovery)
$SteroidsPath = Join-Path $JuiceRoot "Steroids"
if (Test-Path $SteroidsPath) {
    $steroidFiles = Get-ChildItem -Path $SteroidsPath -Filter "*-enhance.ps1" -File -Recurse
    foreach ($f in $steroidFiles) {
        try { . $f.FullName *>$null; __LogOk "Steroid: $($f.BaseName)" } catch { }
    }
}

# ============================================
# Maintenance Commands
# ============================================

function Install-PwshModules {
    $list = @("Terminal-Icons", "posh-git", "PSFzf", "PSReadLine", "oh-my-posh")
    foreach ($m in $list) {
        Write-Host "Installing $m..." -ForegroundColor Cyan
        Install-Module $m -Scope CurrentUser -Force -AllowClobber | Out-Null
    }
}

function Profile-Stats {
    $elapsed = (Get-Date) - $__ProfileStart
    [pscustomobject]@{
        Version    = "3.0.0-alpha"
        LoadTimeMs = [math]::Round($elapsed.TotalMilliseconds, 2)
        Root       = $JuiceRoot
    }
}

# Restore Preferences
$ProgressPreference = $__OldProgressPreference

if ($global:PROFILE_DEBUG) {
    $stats = Profile-Stats
    Write-Host "Juice loaded in $($stats.LoadTimeMs)ms" -ForegroundColor Cyan
}
