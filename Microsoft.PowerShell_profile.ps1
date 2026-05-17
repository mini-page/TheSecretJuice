# ============================================
# PowerShell Profile (Optimized)
# Clean • Fast • Lazy-Load • Minimal Mode • Cached Load Lists
# ============================================

# ---------- Timer ----------
$__ProfileStart = Get-Date

# ---------- Minimal Mode ----------
# Launch minimal shell:
#   $env:PWSH_MINIMAL=1; pwsh
if ($env:PWSH_MINIMAL -eq "1") { return }

# ---------- Silent Boot ----------
$__OldProgressPreference = $ProgressPreference
$__OldInformationPreference = $InformationPreference
$__OldVerbosePreference = $VerbosePreference
$__OldWarningPreference = $WarningPreference

$ProgressPreference    = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference     = 'SilentlyContinue'
$WarningPreference     = 'SilentlyContinue'

# ---------- Debug Switch ----------
# Enable debug logs:
#   $PROFILE_DEBUG = $true; . $PROFILE
$global:PROFILE_DEBUG = $false

function __LogOk($msg)  { if ($global:PROFILE_DEBUG) { Write-Host "✅ $msg" -ForegroundColor Green } }
function __LogWarn($msg){ if ($global:PROFILE_DEBUG) { Write-Host "⚠️ $msg" -ForegroundColor Yellow } }
function __LogErr($msg) { if ($global:PROFILE_DEBUG) { Write-Host "❌ $msg" -ForegroundColor Red } }

# ---------- Utility: Safe Import ----------
function Import-ModuleSafe {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    try {
        Import-Module $Name -ErrorAction Stop | Out-Null
        __LogOk "$Name loaded"
        return $true
    }
    catch {
        __LogWarn "$Name not loaded"
        return $false
    }
}

# ---------- Utility: Lazy Module Loader ----------
# Usage:
#   Enable-LazyModule PSWindowsUpdate Get-WindowsUpdate
function Enable-LazyModule {
    param(
        [Parameter(Mandatory)][string]$ModuleName,
        [Parameter(Mandatory)][string[]]$Commands
    )

    foreach ($cmd in $Commands) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            $scriptblock = [scriptblock]::Create(@"
param([Parameter(ValueFromRemainingArguments=`$true)]`$Args)
Import-Module $ModuleName -ErrorAction SilentlyContinue | Out-Null
& $cmd @Args
"@)

            Set-Item -Path "Function:\global:$cmd" -Value $scriptblock -Force
            __LogOk "Lazy loaded: $ModuleName -> $cmd"
        }
    }
}

# ---------- Utility: Cache file list (for faster startup) ----------
function Get-CachedFileList {
    param(
        [Parameter(Mandatory)][string]$Folder,
        [Parameter(Mandatory)][string]$Filter,
        [Parameter(Mandatory)][string]$CacheFile
    )

    if (-not (Test-Path $Folder)) { return @() }

    $latestWrite = (Get-ChildItem $Folder -Recurse -Force -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1).LastWriteTimeUtc

    if (Test-Path $CacheFile) {
        try {
            $cache = Get-Content $CacheFile -Raw | ConvertFrom-Json
            if ($cache.Folder -eq $Folder -and $cache.Filter -eq $Filter -and $cache.LastWriteUtc -eq $latestWrite) {
                return $cache.Files
            }
        } catch { }
    }

    $files = Get-ChildItem -Path $Folder -Filter $Filter -File -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName

    $obj = [pscustomobject]@{
        Folder       = $Folder
        Filter       = $Filter
        LastWriteUtc = $latestWrite
        Files        = $files
    }

    try {
        $obj | ConvertTo-Json -Depth 4 | Set-Content -Path $CacheFile -Force
    } catch { }

    return $files
}

# ============================================
# Core Initialization
# ============================================

# oh-my-posh (theme)
try {
    oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\PowerShell\highContext.omp.json" | Invoke-Expression
    __LogOk "oh-my-posh initialized"
}
catch {
    __LogWarn "oh-my-posh not loaded"
}

# zoxide
try {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    __LogOk "zoxide initialized"
}
catch {
    __LogWarn "zoxide not loaded"
}

# ============================================
# Modules (do NOT auto-install at startup)
# ============================================
# NOTE: Installing modules inside profile slows startup.
# Use Update-PwshModules or Install-PwshModules function at bottom.

$modules = @(
    'Terminal-Icons',
    'posh-git',
    'Get-ChildItemColor',
    'BurntToast',
    'PSScriptAnalyzer',
    'PSFzf',
    'Posh-SSH'
)

foreach ($m in $modules) {
    Import-ModuleSafe $m | Out-Null
}

# Lazy-load heavy modules (fast startup)
Enable-LazyModule -ModuleName "PSWindowsUpdate" -Commands @(
    "Get-WindowsUpdate",
    "Install-WindowsUpdate",
    "Get-WUHistory"
)

# WinGet CommandNotFound
Import-ModuleSafe "Microsoft.WinGet.CommandNotFound" | Out-Null

# ============================================
# PSReadLine (force latest + safe config)
# ============================================
try {
    $latest = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($latest) {
        Import-Module PSReadLine -RequiredVersion $latest.Version -Force -ErrorAction Stop | Out-Null
        __LogOk "PSReadLine loaded ($($latest.Version))"
    }

    $cmd = Get-Command Set-PSReadLineOption -ErrorAction Stop

    if ($cmd.Parameters.ContainsKey("PredictionSource")) {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    if ($cmd.Parameters.ContainsKey("PredictionViewStyle")) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }

    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -MaximumHistoryCount 1000

    try { Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]27)[90m" } } catch { }

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord

    __LogOk "PSReadLine configured"
}
catch {
    __LogWarn "PSReadLine config skipped: $($_.Exception.Message)"
}

# ============================================
# EasyModules Helpers (safe import)
# ============================================
$helpersPath = "$HOME\Documents\PowerShell\EasyModules\Helpers\helpers.psm1"
if (Test-Path $helpersPath) {
    try {
        Import-Module $helpersPath -Force -ErrorAction Stop | Out-Null
        __LogOk "Helpers loaded"
    }
    catch {
        __LogErr "Helpers failed: $($_.Exception.Message)"
    }
}
else {
    __LogWarn "Helpers not found: $helpersPath"
}

# ============================================
# Load Custom Functions (cached list + silent dot-source)
# ============================================
$easyFuncsPath = "$env:USERPROFILE\Documents\PowerShell\EasyModules"
$easyCache = "$env:USERPROFILE\Documents\PowerShell\.cache_easymodules.json"

$easyFiles = Get-CachedFileList -Folder $easyFuncsPath -Filter "*.ps1" -CacheFile $easyCache
foreach ($f in $easyFiles) {
    try { . $f *>$null } catch { }
}

# ============================================
# Steroids (cached list + silent dot-source)
# ============================================
$SteroidsPath = "$HOME\Documents\PowerShell\Steroids"
$steroidsCache = "$env:USERPROFILE\Documents\PowerShell\.cache_steroids.json"

$steroidFiles = Get-CachedFileList -Folder $SteroidsPath -Filter "*-enhance.ps1" -CacheFile $steroidsCache
foreach ($f in $steroidFiles) {
    try { . $f *>$null } catch { }
}

# ============================================
# Profile Dashboard - Shows stats on startup
# ============================================
try {
    $statsScript = Join-Path $PSScriptRoot "EasyModules\Z-Statistics.ps1"
    if (Test-Path $statsScript) {
        . $statsScript
    }
}
catch { }

# ============================================
# Maintenance Commands (manual use)
# ============================================

function Install-PwshModules {
    $list = @(
        "Terminal-Icons",
        "posh-git",
        "Get-ChildItemColor",
        "BurntToast",
        "PSScriptAnalyzer",
        "PSFzf",
        "PSReadLine",
        "PSWindowsUpdate",
        "Posh-SSH",
        "Microsoft.WinGet.CommandNotFound",
        "Microsoft.WinGet.Client",
        "Microsoft.PowerToys.Configure",
        "WifiTools",
        "PowerType",
        "oh-my-posh"
    )

    foreach ($m in $list) {
        try {
            Install-Module $m -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop | Out-Null
            Write-Host "✅ Installed: $m" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Install failed: $m -> $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Update-PwshModules {
    try {
        Update-Module -Force
        Write-Host "✅ Modules updated" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Update failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Profile-Stats {
    $elapsed = (Get-Date) - $__ProfileStart
    [pscustomobject]@{
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        LoadTimeMs        = [math]::Round($elapsed.TotalMilliseconds, 2)
        MinimalMode       = ($env:PWSH_MINIMAL -eq "1")
        DebugMode         = $global:PROFILE_DEBUG
    }
}

# ---------- Restore Preferences ----------
$ProgressPreference    = $__OldProgressPreference
$InformationPreference = $__OldInformationPreference
$VerbosePreference     = $__OldVerbosePreference
$WarningPreference     = $__OldWarningPreference

# ---------- Optional debug: show load time ----------
if ($global:PROFILE_DEBUG) {
    $elapsed = (Get-Date) - $__ProfileStart
    Write-Host "Profile load time: $([math]::Round($elapsed.TotalMilliseconds,2)) ms" -ForegroundColor Cyan
}
$env:ANTHROPIC_BASE_URL = 'http://localhost:8080'
$env:ANTHROPIC_AUTH_TOKEN = 'test'

function claude-mem { & "C:\Users\umang\.bun\bin\bun.exe" "C:\Users\umang\.claude\plugins\cache\thedotmack\claude-mem\10.6.2\scripts\worker-service.cjs" $args }
