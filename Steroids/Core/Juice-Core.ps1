# Juice-Core.ps1
# Optimized for Performance, Security, and Clean Memory.
# v3.0 Alpha - Hardened & Modular.

$script:Juice = [pscustomobject]@{
    Version = "3.0.0-alpha"
    ModulesPath = Split-Path $PSScriptRoot -Parent
    ActiveSteroids = @()
    BackgroundLoader = $null
}

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
            if ($script:Juice.ActiveSteroids.Count -eq 0) { Write-Host "  • (Loading in background...)" }
            else { foreach ($s in $script:Juice.ActiveSteroids) { Write-Host "  • $s" -ForegroundColor Green } }
            Write-Host ""
        }
        "dashboard" {
            if (Get-Command Start-JuiceDashboard -ErrorAction SilentlyContinue) { Start-JuiceDashboard }
            else { Write-Host "❌ Dashboard not available." -ForegroundColor Red }
        }
        "stats" {
            if (Get-Command Profile-Stats -ErrorAction SilentlyContinue) { Profile-Stats }
            else { Write-Host "❌ Statistics not available." -ForegroundColor Red }
        }
        "version" { Write-Host $script:Juice.Version }
        default { Write-Host "❌ Unknown command: $cmd" -ForegroundColor Red }
    }
}

function Start-JuiceBackgroundLoader {
    try {
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.Open()
        $Powershell = [powershell]::Create().AddScript({
            param($P) 
            # RECURSIVE: Find all steroids in subfolders
            return (Get-ChildItem -Path $P -Filter "*-enhance.ps1" -File -Recurse).BaseName
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
            $script:Juice.BackgroundLoader.PS.Dispose()
            $script:Juice.BackgroundLoader.RS.Close()
            $script:Juice.BackgroundLoader = $null
        }
    }
}

# --- Module Integration ---
$V = Join-Path $PSScriptRoot "Juice-Vault.ps1"
$D = Join-Path $PSScriptRoot "Juice-Dashboard.ps1"
if (Test-Path $V) { . $V }
if (Test-Path $D) { . $D }

# --- Initialize ---
Start-JuiceBackgroundLoader
Write-Host "Juice Core Loaded" -ForegroundColor Green
