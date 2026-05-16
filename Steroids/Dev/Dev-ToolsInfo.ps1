# Dev-ToolsInfo.ps1
# Part of TheSecretJuice - Dev Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Development Tools Information
# ==========================================================
function tools {
    <#
    .SYNOPSIS
    Comprehensive development and system tools checker
    .DESCRIPTION
    Shows installed tools, aliases, functions, versions, and available updates
    .PARAMETER Install
    Install a tool via Scoop
    .PARAMETER Check
    Specify a subset of tools to check
    .PARAMETER Export
    Export the report to a file
    .PARAMETER Updates
    Check if updates are available for installed tools
    .PARAMETER NoVersion
    Skip version checking for faster execution
    #>
    param(
        [string]$Install,
        [string[]]$Check,
        [string]$Export,
        [switch]$Updates,
        [switch]$NoVersion
    )

    # Start timing
    $script:toolsStartTime = Get-Date

    # ----------------------------
    # Tool list
    # ----------------------------
    $commonTools = @(
        "bat", "btop", "broot", "dog", "dust", "eza", "fclones", "fzf", "gdu", "gping",
        "hyperfine", "jq", "lazygit", "oh-my-posh", "procs", "rg", "ffmpeg", "tig", "tree",
        "tldr", "yq", "yt-dlp", "zoxide", "fx",
        "git", "python", "node", "npm", "flutter", "gemini", "go", "rustc", "cargo", "java", "javac",  
        "dotnet", "kubectl", "helm", "docker", "docker-compose", "vscode", "code", "psql", "mysql",    
        "wget", "curl", "aria2", "gh", "aws", "az", "gcloud", "neofetch", "htop", "tmux", "screen",    
        "nmap", "ping", "tracert", "ipconfig", "dig", "nslookup"
    )

    $toolsToCheck = if ($Check) { $commonTools | Where-Object { $_ -in $Check } } else { $commonTools }

    # ----------------------------
    # Handle installation
    # ----------------------------
    if ($Install) {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Color "📦 Installing $Install via Scoop..." Cyan
            try { scoop install $Install } catch { Write-Color "🚫 Failed: $($_.Exception.Message)" Red }
        }
        else {
            Write-Color "Scoop not found. Install first: https://scoop.sh" Red
        }
        return
    }

    # ----------------------------
    # Pre-cache all commands, aliases, and functions for speed
    # ----------------------------
    Write-JuiceBanner -Title "Development Tools"
    Write-Color "⏱️ Scanning tools..." DarkGray

    # More reliable command detection - check each tool individually
    $allCommands = @{}
    $allAliases = @{}
    $allFunctions = @{}

    # Quick pre-check for each tool
    foreach ($tool in $toolsToCheck) {
        try {
            # Try Get-Command first (most reliable)
            $cmd = Get-Command $tool -ErrorAction SilentlyContinue
            if ($cmd) {
                $allCommands[$tool] = $cmd
                continue
            }

            # Check aliases
            $alias = Get-Alias $tool -ErrorAction SilentlyContinue
            if ($alias) {
                $allAliases[$tool] = $alias
                continue
            }

            # Check functions
            $func = Get-Command $tool -CommandType Function -ErrorAction SilentlyContinue
            if ($func) {
                $allFunctions[$tool] = $func
            }
        }
        catch {
            # Tool not found, continue to next
            continue
        }
    }

    # ----------------------------
    # Process tools in parallel (PS 7+) or optimized sequential (PS 5.1)
    # ----------------------------
    $installed = @()
    $missing = @()

    if ($PSVersionTable.PSVersion.Major -ge 7 -and -not $NoVersion) {
        # PowerShell 7+ parallel processing
        $report = $toolsToCheck | ForEach-Object -Parallel {
            $tool = $_
            $allCommands = $using:allCommands
            $allAliases = $using:allAliases
            $allFunctions = $using:allFunctions
            $NoVersion = $using:NoVersion

            $status = ""
            $version = ""

            if ($allCommands.ContainsKey($tool)) {
                $status = "✅ Installed"
                if (-not $NoVersion) {
                    try {
                        # Direct execution - already in parallel runspace, no need for Start-Job       
                        $versionOutput = $null
                        try {
                            $versionOutput = & $tool --version 2>$null
                            if (-not $versionOutput) { $versionOutput = & $tool -v 2>$null }
                            if (-not $versionOutput -and $tool -eq "code") { $versionOutput = & $tool --version 2>$null }
                        }
                        catch { $versionOutput = $null }

                        if ($versionOutput) {
                            $version = ($versionOutput | Select-Object -First 1).ToString().Trim()     
                            # Clean up version string
                            if ($version.Length -gt 50) { $version = $version.Substring(0, 50) + "..." }
                        }
                        else { $version = "✔" }
                    }
                    catch { $version = "✔" }
                }
                else { $version = "✔" }
            }
            elseif ($allAliases.ContainsKey($tool)) {
                $status = "🔗 Alias"
                $version = $allAliases[$tool].Definition
                if ($version.Length -gt 30) { $version = $version.Substring(0, 30) + "..." }
            }
            elseif ($allFunctions.ContainsKey($tool)) {
                $status = "🔧 Function"
                $version = "Available"
            }
            else {
                $status = "🚫 Missing"
                $version = ""
            }

            [PSCustomObject]@{
                Tool        = $tool
                Status      = $status
                Version     = $version
                IsInstalled = $status -ne "🚫 Missing"
            }
        } -ThrottleLimit 10
    }
    else {
        # Sequential processing (PS 5.1 or when NoVersion specified)
        $report = foreach ($tool in $toolsToCheck) {
            $status = ""
            $version = ""
            $isInstalled = $false

            if ($allCommands.ContainsKey($tool)) {
                $isInstalled = $true
                $status = "✅ Installed"
                if (-not $NoVersion) {
                    # Fast version check with timeout
                    try {
                        $job = Start-Job -ScriptBlock {
                            param($t)
                            try {
                                $v = & $t --version 2>$null
                                if (-not $v) { $v = & $t -v 2>$null }
                                return $v
                            }
                            catch { return $null }
                        } -ArgumentList $tool

                        if (Wait-Job $job -Timeout 1) {
                            $versionOutput = Receive-Job $job -ErrorAction SilentlyContinue
                            if ($versionOutput) {
                                $version = ($versionOutput | Select-Object -First 1).ToString().Trim() 
                                if ($version.Length -gt 50) { $version = $version.Substring(0, 50) + "..." }
                            }
                            else { $version = "✔" }
                        }
                        else { $version = "✔" }
                        Remove-Job $job -Force -ErrorAction SilentlyContinue
                    }
                    catch { $version = "✔" }
                }
                else { $version = "✔" }
            }
            elseif ($allAliases.ContainsKey($tool)) {
                $isInstalled = $true
                $status = "🔗 Alias"
                $version = $allAliases[$tool].Definition
                if ($version.Length -gt 30) { $version = $version.Substring(0, 30) + "..." }
            }
            elseif ($allFunctions.ContainsKey($tool)) {
                $isInstalled = $true
                $status = "🔧 Function"
                $version = "Available"
            }
            else {
                $status = "🚫 Missing"
                $version = ""
            }

            [PSCustomObject]@{
                Tool        = $tool
                Status      = $status
                Version     = $version
                IsInstalled = $isInstalled
            }
        }
    }

    # Split into installed and missing
    $installed = $report | Where-Object { $_.IsInstalled }
    $missing = $report | Where-Object { -not $_.IsInstalled }

    # ----------------------------
    # Check for updates if requested
    # ----------------------------
    if ($Updates -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Color "`n🔄 Checking for tool updates via Scoop..." Cyan
        try {
            $scoopStatus = scoop status | Out-String
            foreach ($item in $installed) {
                if ($scoopStatus -match $item.Tool) {
                    $item.Status = "🆙 Update"
                }
            }
        }
        catch {}
    }

    # ----------------------------
    # Display results
    # ----------------------------
    if ($installed) {
        Write-Color "`n✅ Installed Tools ($($installed.Count))" Green
        $installed | Select-Object Tool, Status, Version | Format-Table -AutoSize | Out-String | Write-Host
    }

    if ($missing) {
        Write-Color "`n🚫 Missing Tools ($($missing.Count))" Red
        $missingColumns = 4
        $colWidth = 15
        for ($i = 0; $i -lt $missing.Count; $i += $missingColumns) {
            $row = $missing[$i..($i + $missingColumns - 1)] | ForEach-Object { $_.Tool.PadRight($colWidth) }
            Write-Host "  $($row -join '')" -ForegroundColor Gray
        }
        Write-Color "`n💡 Tip: Install missing tools using 'tools -Install <toolname>'" DarkGray
    }

    # Summary and timing
    $endTime = Get-Date
    $duration = [math]::Round(($endTime - $script:toolsStartTime).TotalSeconds, 2)
    Write-Color "`n📊 Scan completed in $duration seconds." Yellow

    # Export if requested
    if ($Export) {
        $report | Export-Csv -Path $Export -NoTypeInformation
        Write-Color "📄 Report exported to: $Export" Green
    }
}
