# Juice-Core.ps1
# Optimized for Speed & Lazy-Loading.
# v3.1 Stable Core.

$script:Juice = [pscustomobject]@{
    Version = "3.1.0"
    ModulesPath = Split-Path $PSScriptRoot -Parent
    ActiveSteroids = @()
    BackgroundLoader = $null
}

# --- Core Functions ---
function juice {
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    Sync-JuiceBackgroundLoader
    if ($args.Count -eq 0) {
        Write-Host "The Secret Juice v$($script:Juice.Version)" -ForegroundColor Magenta
        Write-Host "Usage: juice <list|dashboard|stats|version>" -ForegroundColor Gray
        return
    }
    $cmd = $args[0]
    switch ($cmd) {
        "list" { 
            Write-Host "`n📦 Active Steroids:" -ForegroundColor Yellow
            if ($script:Juice.ActiveSteroids.Count -eq 0) { Write-Host "  • (Discovery in progress...)" }
            else { foreach ($s in $script:Juice.ActiveSteroids) { Write-Host "  • $s" -ForegroundColor Green } }
            Write-Host ""
        }
        "dashboard" { . (Join-Path $PSScriptRoot "Juice-Dashboard.ps1"); Start-JuiceDashboard }
        "stats"     { . (Join-Path (Split-Path $PSScriptRoot -Parent) "Dev\Z-Statistics.ps1") }
        "version"   { Write-Host $script:Juice.Version }
    }
}

function Start-JuiceBackgroundLoader {
    try {
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.Open()
        $Powershell = [powershell]::Create().AddScript({
            param($P) return (Get-ChildItem -Path $P -Filter "*-enhance.ps1" -File -Recurse).BaseName
        }).AddArgument($script:Juice.ModulesPath)
        $Powershell.Runspace = $Runspace
        $script:Juice.BackgroundLoader = @{ PS = $Powershell; H = $Powershell.BeginInvoke(); RS = $Runspace }
    } catch { }
}

function Sync-JuiceBackgroundLoader {
    if ($script:Juice.BackgroundLoader -and $script:Juice.BackgroundLoader.H.IsCompleted) {
        try {
            $script:Juice.ActiveSteroids = $script:Juice.BackgroundLoader.PS.EndInvoke($script:Juice.BackgroundLoader.H)
        } finally {
            $script:Juice.BackgroundLoader.PS.Dispose(); $script:Juice.BackgroundLoader.RS.Close(); $script:Juice.BackgroundLoader = $null
        }
    }
}

# --- Lazy Loading Helpers ---
function Setup-LazyJuice {
    # Core internal stubs
    . (Join-Path $PSScriptRoot "Juice-Vault.ps1")
    
    # Tool stubs (don't load script until command used)
    function global:lock    { . (Join-Path (Split-Path $PSScriptRoot -Parent) "Security\acllock-enhance.ps1"); acllock @args }
    function global:acllock { . (Join-Path (Split-Path $PSScriptRoot -Parent) "Security\acllock-enhance.ps1"); acllock @args }
    function global:cipher  { . (Join-Path (Split-Path $PSScriptRoot -Parent) "Security\cipher-enhance.ps1"); cipher @args }
    function global:yt-dlp  { . (Join-Path (Split-Path $PSScriptRoot -Parent) "App\yt-dlp-enhance.ps1"); yt-dlp @args }
    function global:update  { . (Join-Path (Split-Path $PSScriptRoot -Parent) "App\Update-Apps.ps1"); update @args }
    function global:optimize { . (Join-Path (Split-Path $PSScriptRoot -Parent) "Sys\Sys-Maintanance.ps1"); optimize @args }

    # Visual stubs (Terminal-Icons trigger)
    function global:ls { if (-not (Get-Module Terminal-Icons)) { Import-Module Terminal-Icons -ErrorAction SilentlyContinue }; Get-ChildItem @args }
    function global:la { if (-not (Get-Module Terminal-Icons)) { Import-Module Terminal-Icons -ErrorAction SilentlyContinue }; Get-ChildItem -Force @args }
    function global:ll { if (-not (Get-Module Terminal-Icons)) { Import-Module Terminal-Icons -ErrorAction SilentlyContinue }; Get-ChildItem @args }
}

# Initialize
Start-JuiceBackgroundLoader
Setup-LazyJuice
Write-Host "Juice Core v3.1 Ready (Lazy Mode)" -ForegroundColor Green
