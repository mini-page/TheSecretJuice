# Restart-specs.ps1
# Part of TheSecretJuice - Sys Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Terminal Management
# ==========================================================
function Restart-Terminal {
    <#
    .SYNOPSIS
    Advanced terminal restart with session preservation and command execution
    .DESCRIPTION
    Restarts the current terminal session with various options for preserving state and executing commands
    .PARAMETER Here
    Restart in the current directory
    .PARAMETER Force
    Skip confirmation prompt
    .PARAMETER Command
    Command to execute after restart
    .PARAMETER Profile
    Reload PowerShell profile after restart
    .PARAMETER Admin
    Restart with administrator privileges
    .PARAMETER NewTab
    Open in a new tab instead of replacing current session
    .PARAMETER Directory
    Specify a custom directory to start in
    .PARAMETER Title
    Set a custom title for the new session
    .PARAMETER Environment
    Preserve current environment variables
    .PARAMETER Delay
    Delay in seconds before executing the restart command
    .EXAMPLE
    Restart-Terminal
    Simple restart
    .EXAMPLE
    Restart-Terminal -Here -Command "Get-ChildItem"
    Restart in current directory and run ls
    .EXAMPLE
    Restart-Terminal -Admin -NewTab
    Open new admin tab
    .EXAMPLE
    Restart-Terminal -Directory "C:\Projects" -Title "Development"
    Start in specific directory with custom title
    #>
    [Alias("restart")]
    param(
        [switch]$Here,
        [switch]$Force,
        [string]$Command,
        [switch]$Profile,
        [switch]$Admin,
        [switch]$NewTab,
        [string]$Directory,
        [string]$Title,
        [switch]$Environment,
        [int]$Delay = 0
    )

    Write-JuiceBanner -Title "Terminal Restart"

    # Confirm restart unless forced
    if (-not $Force -and -not $NewTab) {
        $action = if ($Admin) { "🔄 Restart terminal as Administrator?" } else { "🔄 Restart terminal?" }
        if (-not (Confirm-Action -Message $action)) {
            Write-Color "🚫 Restart cancelled by user." Red
            return
        }
    }

    # Determine starting directory
    $startDir = if ($Directory) {
        $Directory
    }
    elseif ($Here) {
        (Get-Location).Path
    }
    else {
        $null
    }

    # Build the startup command
    $startupCommands = @()

    # Change directory if specified
    if ($startDir) {
        $startupCommands += "Set-Location '$startDir'"
    }

    # Preserve environment variables if requested
    if ($Environment) {
        $envVars = [System.Environment]::GetEnvironmentVariables("Process")
        foreach ($key in $envVars.Keys) {
            if ($key -notin @("PATH", "PSModulePath", "TEMP", "TMP")) {
                $value = $envVars[$key] -replace "'", "''"
                $startupCommands += "`$env:$key = '$value'"
            }
        }
    }

    # Add profile reload if requested
    if ($Profile) {
        $startupCommands += "if (Test-Path `$PROFILE) { . `$PROFILE }"
    }

    # Add delay if specified
    if ($Delay -gt 0) {
        $startupCommands += "Start-Sleep -Seconds $Delay"
    }

    # Add custom command
    if ($Command) {
        # Handle common aliases and ensure proper PowerShell syntax
        $processedCommand = switch -Regex ($Command.Trim()) {
            '^ls$|^dir$' { 'Get-ChildItem' }
            '^ll$' { 'Get-ChildItem | Format-Table -AutoSize' }
            '^la$' { 'Get-ChildItem -Force' }
            '^pwd$' { 'Get-Location' }
            '^ps$' { 'Get-Process' }
            '^cls$|^clear$' { 'Clear-Host' }
            default { $Command }
        }
        $startupCommands += $processedCommand
    }

    # Add welcome message if no other commands
    if (-not $startupCommands -or ($startupCommands.Count -eq 1 -and $startupCommands[0] -like "Set-Location*")) {
        $welcomeMsg = if ($startDir) {
            "Write-Host '🏠 Welcome back to $startDir!' -ForegroundColor Green"
        }
        else {
            "Write-Host '✨ Terminal restarted successfully!' -ForegroundColor Green"
        }
        $startupCommands += $welcomeMsg
    }

    # Combine all commands
    $fullCommand = $startupCommands -join '; '

    # Prepare terminal arguments
    $terminalArgs = @()
    $processArgs = @()

    # Detect terminal type and prepare arguments
    $isWindowsTerminal = $env:WT_SESSION -or $env:TERM_PROGRAM -eq "vscode"
    $isVSCode = $env:TERM_PROGRAM -eq "vscode"

    if ($isWindowsTerminal -and -not $isVSCode) {
        # Windows Terminal
        if ($NewTab) {
            $terminalArgs += "new-tab"
        }
        else {
            $terminalArgs += "new-tab", "--suppressApplicationTitle"
        }

        if ($Admin) {
            $terminalArgs += "--elevate"
        }

        if ($Title) {
            $terminalArgs += "--title", "`"$Title`""
        }

        if ($startDir) {
            $terminalArgs += "--startingDirectory", "`"$startDir`""
        }

        # Add PowerShell with command
        $terminalArgs += "pwsh", "-NoExit", "-Command", "`"$fullCommand`""

        try {
            Write-Color "🖥️ Starting new Windows Terminal session..." Cyan
            if ($Admin) {
                Start-Process "wt" -ArgumentList $terminalArgs -Verb RunAs -ErrorAction Stop
            }
            else {
                Start-Process "wt" -ArgumentList $terminalArgs -ErrorAction Stop
            }
        }
        catch {
            Write-Color "⚠️ Windows Terminal failed, falling back to PowerShell..." Yellow
            $isWindowsTerminal = $false
        }
    }

    if (-not $isWindowsTerminal) {
        # Fallback to direct PowerShell
        $processArgs = @("-NoExit", "-Command", $fullCommand)

        if ($Admin) {
            try {
                Write-Color "🔐 Starting PowerShell as Administrator..." Cyan
                Start-Process "pwsh" -ArgumentList $processArgs -Verb RunAs -ErrorAction Stop
            }
            catch {
                Write-Color "🚫 Failed to start as Administrator. Trying regular PowerShell..." Red    
                Start-Process "pwsh" -ArgumentList $processArgs -ErrorAction Stop
            }
        }
        else {
            Write-Color "🖥️ Starting new PowerShell session..." Cyan
            Start-Process "pwsh" -ArgumentList $processArgs -ErrorAction Stop
        }
    }

    # Show status information
    if ($startDir) { Write-Color "📂 Starting directory: $startDir" White }
    if ($Command) { Write-Color "⚡ Running command: $Command" White }
    if ($Admin) { Write-Color "🔐 Administrator privileges: Requested" White }
    if ($Title) { Write-Color "🏁 Window title: $Title" White }

    # Exit current session unless it's a new tab
    if (-not $NewTab) {
        Write-Color "🚪 Exiting current session in 2 seconds..." Yellow
        Start-Sleep -Seconds 2
        exit
    }
    else {
        Write-Color "✅ New tab opened successfully!" Green
    }
}
# Create shorter aliases
Set-Alias -Name "restart" -Value "Restart-Terminal" -Force
