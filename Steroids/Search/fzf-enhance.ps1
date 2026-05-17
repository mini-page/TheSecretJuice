# fzf-enhance.ps1
# Enhanced fzf PowerShell wrapper with smart presets and settings memory
# Part of TheSecretJuice by mini-page

if ($null -eq (Get-Command Show-JuiceHelp -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path $PSScriptRoot "Core\Juice-Helpers.ps1"
    if (Test-Path $helperPath) { . $helperPath }
}

# Settings file location
$fzfSettingsFile = "$env:USERPROFILE\.fzf-settings.json"

# Load saved settings
function Load-FzfSettings {
    if (Test-Path $fzfSettingsFile) {
        try {
            return Get-Content $fzfSettingsFile | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }
    return $null
}

# Save settings
function Save-FzfSettings {
    param($settings)
    try {
        $settings | ConvertTo-Json | Out-File $fzfSettingsFile -Force
        Write-Host "   OK. Settings saved!" -ForegroundColor Green
    }
    catch {
        Write-Host "   WARNING: Could not save settings" -ForegroundColor Yellow
    }
}

function fz {
    param(
        [string]$query,
        [switch]$useDefaults
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       FZF Interactive        ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Check if fzf is installed
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: fzf not found in PATH." -ForegroundColor Red
        Write-Host "Please install it from: https://github.com/junegunn/fzf" -ForegroundColor Yellow
        return
    }

    # Load saved settings
    $settings = Load-FzfSettings
    if (-not $settings) {
        $settings = @{
            previewEnabled = $true
            defaultEditor = "code"
        }
    }

    Write-Host "Select a mode:" -ForegroundColor Cyan
    Write-Host "   1. 📂 File Search (with Preview)" -ForegroundColor White
    Write-Host "   2. ⚙️ Process Killer" -ForegroundColor White
    Write-Host "   3. 📚 Command History" -ForegroundColor White
    Write-Host "   4. 🛠️ Configure Settings" -ForegroundColor White
    Write-Host "   q. Exit" -ForegroundColor Gray
    
    $choice = Read-Host "`n   Choice"
    
    switch ($choice) {
        "1" { Invoke-FzfFileSearch -settings $settings -query $query }
        "2" { Invoke-FzfProcessKiller }
        "3" { Invoke-FzfHistorySearch }
        "4" { 
            $settings.previewEnabled = (Read-Host "   Enable Previews? (y/n, current: $(if($settings.previewEnabled){'y'}else{'n'}))") -eq 'y'
            $settings.defaultEditor = Read-Host "   Default Editor command (current: $($settings.defaultEditor))"
            Save-FzfSettings -settings $settings
        }
        "q" { return }
        default { Write-Host "Invalid choice." -ForegroundColor Red }
    }
}

function Invoke-FzfFileSearch {
    param($settings, $query)
    
    $previewCmd = ""
    if ($settings.previewEnabled) {
        if (Get-Command bat -ErrorAction SilentlyContinue) {
            $previewCmd = "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
        } else {
            $previewCmd = "--preview 'type {}'"
        }
    }

    $fzfCmd = "fzf $previewCmd --header 'Enter to Open | Alt-C to Copy Path' --query '$query'"
    $selection = Invoke-Expression $fzfCmd

    if ($selection) {
        Write-Host "`nSelected: $selection" -ForegroundColor Cyan
        Write-Host "   1. Open with $($settings.defaultEditor)" -ForegroundColor White
        Write-Host "   2. Open with Notepad" -ForegroundColor White
        Write-Host "   3. Copy path to clipboard" -ForegroundColor White
        $act = Read-Host "   Action (default: 1)"
        
        switch ($act) {
            "2" { notepad $selection }
            "3" { $selection | Set-Clipboard; Write-Host "Copied!" -ForegroundColor Green }
            default { 
                try { Start-Process $settings.defaultEditor -ArgumentList $selection -ErrorAction Stop }
                catch { Write-Host "Could not start $($settings.defaultEditor). Opening with Notepad instead." -ForegroundColor Yellow; notepad $selection }
            }
        }
    }
}

function Invoke-FzfProcessKiller {
    Write-Host "Searching processes..." -ForegroundColor Gray
    $proc = Get-Process | Select-Object Id, ProcessName, CPU, WorkingSet | Out-String -Stream | fzf --header "Select process to KILL (Enter)" --header-lines 3
    if ($proc) {
        $id = ($proc -split '\s+')[1]
        if ($id -match '^\d+$') {
            $confirm = Read-Host "Kill process $id? (y/N)"
            if ($confirm -eq 'y') {
                Stop-Process -Id $id -Force
                Write-Host "Process $id terminated." -ForegroundColor Green
            }
        }
    }
}

function Invoke-FzfHistorySearch {
    $history = Get-Content (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
    if (-not $history) {
        Write-Host "No history found." -ForegroundColor Yellow
        return
    }
    $selected = $history | Select-Object -Unique | fzf --tac --header "Select command to EXECUTE"
    if ($selected) {
        Write-Host "Executing: $selected" -ForegroundColor Cyan
        Invoke-Expression $selected
    }
}

# Aliases
Set-Alias -Name fzf-file -Value Invoke-FzfFileSearch -Description "TheSecretJuice: Quick fzf file search"
# Note: Base fz command is the interactive entry point

function fzf-help {
    $cmds = @(
        @{ Cmd="fz"; Desc="Main menu" },
        @{ Cmd="fzf-file"; Desc="Search files" },
        @{ Cmd="Invoke-FzfProcessKiller"; Desc="Kill proc" },
        @{ Cmd="Invoke-FzfHistorySearch"; Desc="PS History" },
        @{ Cmd="fzf-help"; Desc="Show this help menu" }
    )
    Show-JuiceHelp -Title "fzf-enhance Steroids" -Commands $cmds
}
Set-Alias -Name "fzf-help" -Value fzf-help

Write-Host "OK. fzf-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'fzf-help' for commands" -ForegroundColor Cyan
