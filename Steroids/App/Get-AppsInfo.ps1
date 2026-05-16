# Get-AppsInfo.ps1
# Part of TheSecretJuice - App Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Application Management via source
# ==========================================================
function apps {
    <#
    .SYNOPSIS
    List installed applications, packages, and optionally aliases, paths, and modules
    .PARAMETER Source
    Specify source: All, Winget, Scoop, Choco, Registry
    .PARAMETER Export
    Export list to file
    .PARAMETER Details
    Extra details: Aliases, Paths, Modules, All
    .EXAMPLE
    apps
    List all installed applications
    .EXAMPLE
    apps -Source Scoop
    List only Scoop applications
    .EXAMPLE
    apps -Details Aliases
    Show installed apps plus available aliases
    #>
    param(
        [ValidateSet('All', 'Winget', 'Scoop', 'Choco', 'Registry')]
        [string]$Source = 'All',
        [string]$Export,
        [ValidateSet('None', 'Aliases', 'Paths', 'Modules', 'All')]
        [string]$Details = 'None'
    )

    Write-JuiceBanner -Title "Application Inventory"

    $results = @()

    if ($Source -eq 'All' -or $Source -eq 'Registry') {
        Write-Color "🔍 Checking Windows Registry..." Cyan
        $regApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |      
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher |
        Sort-Object DisplayName
        $results += @{Source = "Registry"; Count = $regApps.Count; Data = $regApps }
    }

    if (($Source -eq 'All' -or $Source -eq 'Winget') -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Color "🔍 Checking Winget..." Cyan
        $wingetList = winget list --accept-source-agreements 2>$null
        $results += @{Source = "Winget"; Count = ($wingetList.Count - 3); Data = $wingetList }
    }

    if (($Source -eq 'All' -or $Source -eq 'Scoop') -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Color "🔍 Checking Scoop..." Cyan
        $scoopList = scoop list 2>$null
        $results += @{Source = "Scoop"; Count = $scoopList.Count; Data = $scoopList }
    }

    if (($Source -eq 'All' -or $Source -eq 'Choco') -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Color "🔍 Checking Chocolatey..." Cyan
        $chocoList = choco list --local-only 2>$null
        $results += @{Source = "Chocolatey"; Count = $chocoList.Count; Data = $chocoList }
    }

    # Display results
    foreach ($result in $results) {
        Write-Color "`n📦 $($result.Source) - $($result.Count) items" Yellow
        if ($result.Source -eq "Registry") {
            $result.Data | Format-Table -AutoSize | Out-String | Write-Host
        }
        else {
            $result.Data | Out-String | Write-Host
        }
    }

    # Extra details
    if ($Details -ne 'None') {
        Write-Color "`n⚙️ Extra Details ($Details)" Magenta

        if ($Details -eq 'Aliases' -or $Details -eq 'All') {
            Write-Color "`n🔑 Aliases" Yellow
            Get-Alias | Sort-Object Name | Format-Table Name, Definition -AutoSize | Out-String | Write-Host
        }

        if ($Details -eq 'Paths' -or $Details -eq 'All') {
            Write-Color "`n📂 Environment PATH" Yellow
            $env:Path -split ";" | Sort-Object | ForEach-Object { Write-Host "• $_" }
        }

        if ($Details -eq 'Modules' -or $Details -eq 'All') {
            Write-Color "`n📦 PowerShell Modules" Yellow
            Get-Module -ListAvailable | Sort-Object Name | Select-Object Name, Version | Format-Table -AutoSize | Out-String | Write-Host
        }
    }

    # Export if requested
    if ($Export) {
        $exportContent = "=== Installed Applications ===`nGenerated: $(Get-Date)`n"
        foreach ($result in $results) {
            $exportContent += "`n[$($result.Source)] - $($result.Count) items`n"
            $exportContent += "=" * 50 + "`n"
            $exportContent += ($result.Data | Out-String)
        }
        if ($Details -ne 'None') {
            $exportContent += "`n=== Extra Details: $Details ===`n"
            if ($Details -eq 'Aliases' -or $Details -eq 'All') {
                $exportContent += (Get-Alias | Out-String)
            }
            if ($Details -eq 'Paths' -or $Details -eq 'All') {
                $exportContent += ($env:Path -split ";" | Out-String)
            }
            if ($Details -eq 'Modules' -or $Details -eq 'All') {
                $exportContent += (Get-Module -ListAvailable | Out-String)
            }
        }
        $exportContent | Out-File $Export -Encoding UTF8
        Write-Color "`n📄 Exported to: $Export" Green
    }
}
