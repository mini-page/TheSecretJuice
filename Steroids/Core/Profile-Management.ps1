# Profile-Management.ps1
# Part of TheSecretJuice - Core Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Profile Management
# ==========================================================
function Profile {
    <#
    .SYNOPSIS
    Unified PowerShell profile management
    .DESCRIPTION
    Comprehensive profile management with editing, reloading, backup, and comparison features
    .PARAMETER Action
    Action to perform: Edit, Reload, Backup, Compare, List, EditCommands
    .PARAMETER Editor
    Editor to use for editing operations
    .PARAMETER AutoBackup
    Create backup before editing
    .PARAMETER Force
    Skip confirmations
    .EXAMPLE
    profile -Action Reload
    Reload the current profile
    .EXAMPLE
    profile -Action Edit -Editor code -AutoBackup
    Edit profile with VS Code after creating backup
    .EXAMPLE
    profile -Action EditCommands -Editor code
    Edit EasyCommands script
    .EXAMPLE
    profile -Action Compare
    Compare current profile with latest backup
    #>
    [Alias("profile")]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('Edit', 'Reload', 'Backup', 'Compare', 'List', 'EditCommands')]
        [string]$Action = 'Reload',

        [ValidateSet('code', 'code-insiders', 'notepad', 'nano', 'vim', 'auto')]
        [string]$Editor = 'auto',

        [switch]$AutoBackup,
        [switch]$Force
    )

    Write-JuiceBanner -Title "Profile Management"

    # Helper function for editor detection and invocation
    function Invoke-SmartEditor {
        param([string]$EditorChoice, [string]$FilePath)

        if ($EditorChoice -eq 'auto') {
            $EditorChoice = if (Get-Command code -ErrorAction SilentlyContinue) { 'code' }
            elseif (Get-Command code-insiders -ErrorAction SilentlyContinue) { 'code-insiders' }       
            elseif (Get-Command vim -ErrorAction SilentlyContinue) { 'vim' }
            else { 'notepad' }
        }

        $editorCommands = @{
            'code'          = { if (Get-Command code -ErrorAction SilentlyContinue) { code $FilePath } else { throw "VS Code not found" } }
            'code-insiders' = { if (Get-Command code-insiders -ErrorAction SilentlyContinue) { code-insiders $FilePath } else { throw "VS Code Insiders not found" } }
            'vim'           = { if (Get-Command vim -ErrorAction SilentlyContinue) { vim $FilePath } else { throw "Vim not found" } }
            'nano'          = { if (Get-Command nano -ErrorAction SilentlyContinue) { nano $FilePath } else { throw "Nano not found" } }
            'notepad'       = { notepad $FilePath }
        }

        try {
            Write-Color "📂 Opening with $EditorChoice..." Cyan
            & $editorCommands[$EditorChoice]
        }
        catch {
            Write-Color "⚠️ $EditorChoice not available. Using notepad..." Yellow
            notepad $FilePath
        }
    }

    # Main action switch
    switch ($Action) {
        'Reload' {
            Write-Color "🔄 Reloading PowerShell profile..." Yellow

            if (-not (Test-Path $PROFILE)) {
                Write-Color "🚫 No profile found at: $PROFILE" Red
                return
            }

            try {
                . $PROFILE
                Write-Color "✅ Profile reloaded successfully!" Green

                # Check for EasyCommands
                if (Get-Command sys -ErrorAction SilentlyContinue) {
                    Write-Color "✅ EasyCommands detected and loaded" Green
                }
            }
            catch {
                Write-Color "🚫 Error reloading profile: $($_.Exception.Message)" Red
            }
        }

        'Edit' {
            if ($AutoBackup -and (Test-Path $PROFILE)) {
                Write-Color "💾 Creating backup before editing..." Yellow
                $this = $PSCmdlet.MyInvocation.MyCommand
                & $this -Action Backup
            }

            if (-not (Test-Path $PROFILE)) {
                if ($Force -or (Read-Host "Profile not found. Create it? (y/N)") -eq 'y') {
                    Write-Color "📄 Creating new profile..." Yellow
                    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
                    Write-Color "✅ Profile created at: $PROFILE" Green
                }
                else {
                    Write-Color "🚫 Operation cancelled" Red
                    return
                }
            }

            Invoke-SmartEditor $Editor $PROFILE
        }

        'EditCommands' {
            $scriptPath = Join-Path (Split-Path $PROFILE) "easy_v3.ps1"

            if (-not (Test-Path $scriptPath)) {
                # Try alternative locations
                $altPaths = @(
                    Join-Path (Split-Path $PROFILE) "EasyCommands.ps1",
                    Join-Path (Split-Path $PROFILE) "easy.ps1"
                )

                $scriptPath = $altPaths | Where-Object { Test-Path $_ } | Select-Object -First 1       

                if (-not $scriptPath) {
                    Write-Color "🚫 EasyCommands script not found in profile directory" Red
                    Write-Color "Searched for: easy_v3.ps1, EasyCommands.ps1, easy.ps1" DarkGray       
                    return
                }
            }

            Write-Color "📂 Found EasyCommands at: $(Split-Path $scriptPath -Leaf)" Green
            Invoke-SmartEditor $Editor $scriptPath
        }

        'Backup' {
            if (-not (Test-Path $PROFILE)) {
                Write-Color "🚫 No profile found to backup" Red
                return
            }

            $backupDir = Join-Path (Split-Path $PROFILE) "ProfileBackups"
            if (-not (Test-Path $backupDir)) {
                New-Item -Path $backupDir -ItemType Directory | Out-Null
                Write-Color "📂 Created backup directory: $backupDir" Green
            }

            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupFile = Join-Path $backupDir "profile_$timestamp.ps1"

            Copy-Item $PROFILE $backupFile
            Write-Color "💾 Backup created: profile_$timestamp.ps1" Green
            Write-Color "📂 Location: $backupDir" DarkGray
        }

        'Compare' {
            $backupDir = Join-Path (Split-Path $PROFILE) "ProfileBackups"

            if (-not (Test-Path $backupDir)) {
                Write-Color "🚫 No backup directory found" Red
                return
            }

            $latestBackup = Get-ChildItem $backupDir -Filter "profile_*.ps1" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

            if (-not $latestBackup) {
                Write-Color "🚫 No backup files found" Red
                return
            }

            Write-Color "🔍 Comparing current profile with: $($latestBackup.Name)" Cyan
            Write-Color "Backup from: $($latestBackup.LastWriteTime)" DarkGray

            try {
                $differences = Compare-Object (Get-Content $PROFILE) (Get-Content $latestBackup.FullName) -IncludeEqual
                $changes = $differences | Where-Object { $_.SideIndicator -ne '==' }

                if ($changes) {
                    Write-Color "📊 Found $($changes.Count) differences:" Yellow
                    $changes | ForEach-Object {
                        $symbol = if ($_.SideIndicator -eq '<=') { "+" } else { "-" }
                        $color = if ($_.SideIndicator -eq '<=') { "Green" } else { "Red" }
                        Write-Color "$symbol $($_.InputObject)" $color
                    }
                }
                else {
                    Write-Color "✅ No differences found - profiles are identical" Green
                }
            }
            catch {
                Write-Color "🚫 Error comparing files: $($_.Exception.Message)" Red
            }
        }

        'List' {
            Write-Color "📋 PowerShell Profile Locations:" Cyan
            Write-Color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" DarkGray

            $profiles = @(
                @{ Name = "Current User, Current Host"; Path = $PROFILE.CurrentUserCurrentHost; Active = ($PROFILE -eq $PROFILE.CurrentUserCurrentHost) },
                @{ Name = "Current User, All Hosts"; Path = $PROFILE.CurrentUserAllHosts; Active = ($PROFILE -eq $PROFILE.CurrentUserAllHosts) },
                @{ Name = "All Users, Current Host"; Path = $PROFILE.AllUsersCurrentHost; Active = ($PROFILE -eq $PROFILE.AllUsersCurrentHost) },
                @{ Name = "All Users, All Hosts"; Path = $PROFILE.AllUsersAllHosts; Active = ($PROFILE -eq $PROFILE.AllUsersAllHosts) }
            )

            foreach ($prof in $profiles) {
                $status = if (Test-Path $prof.Path) {
                    $size = [math]::Round((Get-Item $prof.Path).Length / 1KB, 1)
                    "✅ Exists ($size KB)"
                }
                else {
                    "🚫 Not found"
                }

                $marker = if ($prof.Active) { " 👈 ACTIVE" } else { "" }
                Write-Host "$($prof.Name):" -ForegroundColor White
                Write-Host "  $($prof.Path)" -ForegroundColor DarkGray
                Write-Host "  $status$marker" -ForegroundColor $(if ($status.StartsWith("✅")) { "Green" } else { "Red" })
                Write-Host ""
            }

            # Show backup info
            $backupDir = Join-Path (Split-Path $PROFILE) "ProfileBackups"
            if (Test-Path $backupDir) {
                $backupCount = (Get-ChildItem $backupDir -Filter "profile_*.ps1" -ErrorAction SilentlyContinue).Count
                Write-Color "💾 Backups available: $backupCount" Green
            }
        }
    }
}
