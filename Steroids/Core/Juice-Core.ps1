# Juice-Core.ps1
# Optimized for Performance, Security, and Clean Memory.

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
        return
    }
    $cmd = $args[0]
    switch ($cmd) {
        "list" { 
            Write-Host "Active Steroids:" -ForegroundColor Yellow
            if ($script:Juice.ActiveSteroids.Count -eq 0) { Write-Host "  (Loading...)" }
            else { foreach ($s in $script:Juice.ActiveSteroids) { Write-Host "  * $s" } }
        }
        "version" { Write-Host $script:Juice.Version }
    }
}

function Start-JuiceBackgroundLoader {
    try {
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.Open()
        $Powershell = [powershell]::Create().AddScript({
            param($P) return (Get-ChildItem -Path $P -Filter "*-enhance.ps1" -File).BaseName
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

$V = Join-Path $PSScriptRoot "Juice-Vault.ps1"
if (Test-Path $V) { . $V }

Start-JuiceBackgroundLoader
Write-Host "Juice Core Loaded" -ForegroundColor Green
