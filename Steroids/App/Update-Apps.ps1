# Update-Apps.ps1
# Part of TheSecretJuice - App Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Application Update Manager
# ==========================================================
function update {
    <#
    .SYNOPSIS
    Universal package manager update wrapper
    .DESCRIPTION
    Aggregates and executes updates across multiple package managers (Winget, Scoop, Choco, etc.)
    .PARAMETER All
    Update all available package managers
    .PARAMETER Sources
    Specific sources to update (e.g. winget, scoop)
    .PARAMETER AutoYes
    Automatically accept all update prompts
    .PARAMETER CheckOnly
    Only check for updates without installing
    .PARAMETER Comparison
    Show version comparison (current -> latest)
    .PARAMETER DebugLog
    Save detailed update logs
    .PARAMETER Force
    Force update even if no changes detected
    .PARAMETER Fast
    Skip pre-update checks and backups
    .EXAMPLE
    update
    Update common package managers
    .EXAMPLE
    update -All -AutoYes
    Update everything silently
    .EXAMPLE
    update -Sources Winget,Scoop -CheckOnly
    Check for updates in specific sources
    #>
    param(
        [switch]$All,
        [string[]]$Sources,
        [switch]$AutoYes,
        [switch]$CheckOnly,
        [switch]$Comparison,
        [switch]$DebugLog,
        [switch]$Force,
        [switch]$Fast
    )

    $reportPath = Join-Path $env:TEMP "update_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

    # Define package managers and their commands
    $packageManagers = @{
        'Winget' = @{
            Command      = 'winget'
            CheckCmd     = { winget list --upgrade --accept-source-agreements 2>$null | Out-String }
            UpdateCmd    = { winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements }
            ParseUpdates = { param($output) $output -match '\[.*\]' }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '\[.*\]' } | ForEach-Object {
                    if ($_ -match '^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)') {
                        [PSCustomObject]@{ Name = $matches[1]; Current = $matches[3]; Available = $matches[4]; Source = "Winget" }
                    }
                }
            }
        }
        'Scoop'  = @{
            Command      = 'scoop'
            CheckCmd     = { scoop status 2>&1 | Out-String }
            UpdateCmd    = { scoop update * }
            ParseUpdates = { param($output) $output -match 'Updates available' }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match ':' } | ForEach-Object {
                    if ($_ -match '^\s+(\S+):\s+(\S+)\s+->\s+(\S+)') {
                        [PSCustomObject]@{ Name = $matches[1]; Current = $matches[2]; Available = $matches[3]; Source = "Scoop" }
                    }
                }
            }
        }
        'Choco'  = @{
            Command      = 'choco'
            CheckCmd     = { choco outdated 2>&1 | Out-String }
            UpdateCmd    = { choco upgrade all -y }
            ParseUpdates = { param($output) $output -match 'outdated' }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '\|' } | ForEach-Object {
                    $parts = $_ -split '\|'
                    if ($parts.Count -ge 3) {
                        [PSCustomObject]@{ Name = $parts[0]; Current = $parts[1]; Available = $parts[2]; Source = "Chocolatey" }
                    }
                }
            }
        }
        'Npm'    = @{
            Command      = 'npm'
            CheckCmd     = { npm outdated -g 2>&1 | Out-String }
            UpdateCmd    = {
                $outdated = npm outdated -g --json | ConvertFrom-Json
                $outdated.PSObject.Properties | ForEach-Object { npm install -g $_.Name }
            }
            ParseUpdates = { param($output) $output -ne "" }
            GetPackages  = { param($output)
                try {
                    $json = npm outdated -g --json | ConvertFrom-Json
                    $json.PSObject.Properties | ForEach-Object {
                        [PSCustomObject]@{ Name = $_.Name; Current = $_.Value.current; Available = $_.Value.latest; Source = "NPM Global" }
                    }
                }
                catch { @() }
            }
        }
        'Go'     = @{
            Command      = 'go'
            CheckCmd     = { go list -u -m all 2>&1 | Out-String }
            UpdateCmd    = { go get -u ./... }
            ParseUpdates = { param($output)
                $output -match '\[.*\]' # Go shows [latest] for updates available
            }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '\[.*\]' } | ForEach-Object {
                    if ($_ -match '^(\S+)\s+(\S+)\s+\[(\S+)\]') {
                        [PSCustomObject]@{ Name = $matches[1]; Current = $matches[2]; Available = $matches[3]; Source = "Go Modules" }
                    }
                }
            }
        }
        'Cargo'  = @{
            Command      = 'cargo'
            CheckCmd     = { cargo install-update --list 2>&1 | Out-String }
            UpdateCmd    = { cargo install-update --all }
            ParseUpdates = { param($output)
                $output -match 'Updates available' -or $output -match 'Updating'
            }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '->' } | ForEach-Object {
                    if ($_ -match '^(\S+)\s+(\S+)\s+->\s+(\S+)') {
                        [PSCustomObject]@{ Name = $matches[1]; Current = $matches[2]; Available = $matches[3]; Source = "Cargo" }
                    }
                }
            }
        }
        'Pip'    = @{
            Command      = 'pip'
            CheckCmd     = { pip list --outdated --format=json 2>$null | Out-String }
            UpdateCmd    = {
                $outdated = pip list --outdated --format=json 2>$null | ConvertFrom-Json
                $outdated | ForEach-Object { pip install --upgrade $_.name }
            }
            ParseUpdates = { param($output)
                try { $json = $output | ConvertFrom-Json; $json.Count -gt 0 } catch { $false }
            }
            GetPackages  = { param($output)
                try {
                    $json = $output | ConvertFrom-Json
                    $json | ForEach-Object {
                        [PSCustomObject]@{
                            Name      = $_.name
                            Current   = $_.version
                            Available = $_.latest_version
                            Source    = "Python Pip"
                        }
                    }
                }
                catch { @() }
            }
        }
        'Gem'    = @{
            Command      = 'gem'
            CheckCmd     = { gem outdated 2>&1 | Out-String }
            UpdateCmd    = { gem update }
            ParseUpdates = { param($output)
                $output -match '\(.*current:.*\)'
            }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '\(.*current:.*\)' } | ForEach-Object { 
                    if ($_ -match '^(\S+)\s+\((.*)\s+current:\s+(\S+)\)') {
                        [PSCustomObject]@{ Name = $matches[1]; Current = $matches[3]; Available = $matches[2]; Source = "Ruby Gem" }
                    }
                }
            }
        }
        'Dotnet' = @{
            Command      = 'dotnet'
            CheckCmd     = { dotnet tool list -g 2>&1 | Out-String }
            UpdateCmd    = {
                $tools = dotnet tool list -g | Select-String -Pattern "^\S+\s+" | ForEach-Object { ($_ -split '\s+')[0] }
                $tools | ForEach-Object { dotnet tool update -g $_ }
            }
            ParseUpdates = { param($output)
                # For .NET tools, we'll assume updates are available if tools are installed
                $output -match '\S+\s+\S+\s+\S+'
            }
            GetPackages  = { param($output)
                $output -split "`n" | Where-Object { $_ -match '^\S+\s+\S+\s+\S+' } | ForEach-Object { 
                    $parts = $_ -split '\s+'
                    if ($parts.Count -ge 2) {
                        [PSCustomObject]@{ Name = $parts[0]; Current = $parts[1]; Available = "Latest"; Source = ".NET Tools" }
                    }
                }
            }
        }
    }

    # Determine which package managers to use
    $managersToUse = @()

    if ($All) {
        # Use all detected package managers
        foreach ($mgr in $packageManagers.Keys) {
            if (Get-Command $packageManagers[$mgr].Command -ErrorAction SilentlyContinue) {
                $managersToUse += $mgr
            }
        }
    }
    elseif ($Sources.Count -gt 0) {
        # Use specified sources
        foreach ($source in $Sources) {
            if ($packageManagers.ContainsKey($source)) {
                if (Get-Command $packageManagers[$source].Command -ErrorAction SilentlyContinue) {     
                    $managersToUse += $source
                }
                else {
                    Write-Color "⚠️ $source not found on system" Yellow
                }
            }
        }
    }
    else {
        # Default behavior - use common package managers
        $defaultSources = @('Winget', 'Scoop', 'Choco')
        foreach ($source in $defaultSources) {
            if ($packageManagers.ContainsKey($source) -and (Get-Command $packageManagers[$source].Command -ErrorAction SilentlyContinue)) {
                $managersToUse += $source
            }
        }
    }

    if ($managersToUse.Count -eq 0) {
        Write-Color "🚫 No package managers found or specified!" Red
        Write-Color "Available sources: $($packageManagers.Keys -join ', ')" DarkGray
        return
    }

    Write-JuiceBanner -Title "Application Updates"
    Write-Color "`n🎯 Checking updates for: $($managersToUse -join ', ')" Cyan

    # Check for updates
    $results = @()
    foreach ($mgr in $managersToUse) {
        $config = $packageManagers[$mgr]
        Write-Color "Checking $mgr..." DarkGray

        try {
            $output = & $config.CheckCmd
            $hasUpdates = & $config.ParseUpdates -output $output
            $packages = if ($Comparison) { & $config.GetPackages -output $output } else { @() }        

            $results += [PSCustomObject]@{
                Manager    = $mgr
                Output     = $output
                HasUpdates = $hasUpdates
                Packages   = $packages
            }
        }
        catch {
            Write-Color "⚠️ Error checking $mgr $($_.Exception.Message)" Yellow
            if ($DebugLog) {
                "ERROR checking $mgr`: $($_.Exception.Message)" | Out-File $reportPath -Append
            }
        }
    }

    # Display results
    Write-Color "`n📦 Update Summary:" Yellow
    $hasAnyUpdates = $false

    foreach ($result in $results) {
        if ($result.HasUpdates -or $Force) {
            Write-Color "📦 $($result.Manager): Updates available" Green
            $hasAnyUpdates = $true

            if ($Comparison -and $result.Packages.Count -gt 0) {
                Write-Color "   Packages to update:" DarkGray
                $result.Packages | ForEach-Object {
                    Write-Color "   • $($_.Name): $($_.Current) → $($_.Available)" Cyan
                }
            }
        }
        else {
            Write-Color "✅ $($result.Manager): Up to date" Green
        }
    }

    if (-not $hasAnyUpdates -and -not $Force) {
        Write-Color "`n✨ All specified sources are up to date!" Green
        return
    }

    if ($CheckOnly) {
        Write-Color "`n🔍 Check completed. Use without -CheckOnly to install updates." Yellow
        return
    }

    # Confirm updates
    if (-not $AutoYes -and -not $Fast) {
        $sourcesToUpdate = ($results | Where-Object { $_.HasUpdates -or $Force }).Manager -join ', '   
        if (-not (Read-Host "`nProceed with updating $sourcesToUpdate? (y/N)") -eq 'y') {
            Write-Color "🚫 Update cancelled by user." Red
            return
        }
    }

    # Perform updates
    Write-Color "`n🚀 Starting updates..." Green

    foreach ($result in $results) {
        if ($result.HasUpdates -or $Force) {
            $mgr = $result.Manager
            $config = $packageManagers[$mgr]

            Write-Color "📦 Updating $mgr packages..." Cyan
            try {
                & $config.UpdateCmd
                Write-Color "✅ $mgr updated successfully" Green
            }
            catch {
                Write-Color "🚫 $mgr update failed: $($_.Exception.Message)" Red
                if ($DebugLog) {
                    "ERROR updating $mgr`: $($_.Exception.Message)" | Out-File $reportPath -Append     
                }
            }
        }
    }

    Write-Color "`n🎉 Update process complete!" Green
    if ($DebugLog) {
        Write-Color "📝 Detailed log: $reportPath" DarkGray
    }
}
