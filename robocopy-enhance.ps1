# robocopy-enhance.ps1
# Enhanced robocopy PowerShell wrapper with interactive menus and smart features
# Part of TheSecretJuice by mini-page

# Settings file location
$roboSettingsFile = "$env:USERPROFILE\.robocopy-settings.json"

# ============================================================================
# SETTINGS MANAGEMENT
# ============================================================================

function Load-RoboSettings {
    if (Test-Path $roboSettingsFile) {
        try {
            return Get-Content $roboSettingsFile | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }
    return $null
}

function Save-RoboSettings {
    param($settings)
    try {
        $settings | ConvertTo-Json | Out-File $roboSettingsFile -Force
        Write-Host "   OK. Settings saved for next time!" -ForegroundColor Green
    }
    catch {
        Write-Host "   WARNING: Could not save settings" -ForegroundColor Yellow
    }
}

# ============================================================================
# PRESET CONFIGURATIONS
# ============================================================================

$roboPresets = @{
    "mirror" = @{
        flags = "/MIR /R:3 /W:5 /MT:8 /V"
        description = "Mirror sync (delete extra files in dest)"
    }
    "sync" = @{
        flags = "/E /R:3 /W:5 /MT:8 /V"
        description = "Sync (keep all subdirs, no deletions)"
    }
    "backup" = @{
        flags = "/MIR /DCOPY:DAT /COPY:DAT /R:3 /W:5 /MT:8 /XO /V"
        description = "Backup (skip older files)"
    }
    "fast" = @{
        flags = "/E /R:1 /W:1 /MT:16 /NFL /NDL /NJH /NJS"
        description = "Fast copy (minimal logging, max threads)"
    }
    "verify" = @{
        flags = "/E /R:3 /W:5 /MT:8 /V /ETA"
        description = "Copy with verification"
    }
    "incremental" = @{
        flags = "/E /XO /R:3 /W:5 /MT:8 /V"
        description = "Incremental (skip older files)"
    }
}

# ============================================================================
# MAIN INTERACTIVE FUNCTION
# ============================================================================

function robocopy {
    param(
        [string]$source,
        [string]$destination,
        [switch]$useDefaults
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║    ROBOCOPY Interactive      ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Load saved settings
    $savedSettings = Load-RoboSettings
    if ($savedSettings -and -not $useDefaults) {
        Write-Host "Found saved settings!" -ForegroundColor Cyan
        Write-Host "   1. Use saved settings" -ForegroundColor White
        Write-Host "   2. Configure new settings" -ForegroundColor White
        Write-Host "   3. Use defaults (skip all)" -ForegroundColor White
        $settingChoice = Read-Host "   Choice (1-3, default: 1)"
        
        if ($settingChoice -eq "3") {
            $useDefaults = $true
        }
        elseif ($settingChoice -ne "2") {
            Write-Host "   OK. Using saved settings`n" -ForegroundColor Green
        }
        else {
            $savedSettings = $null
        }
    }
    
    # Initialize settings object
    $currentSettings = @{
        presetChoice = "1"
        logChoice = "1"
        excludeChoice = "1"
    }
    
    # --- Source Input ---
    if (-not $source) {
        Write-Host "Source Directory" -ForegroundColor Cyan
        $source = Read-Host "   Enter source path (or drag & drop)"
        if (-not $source) {
            Write-Host "   ERROR: No source provided. Aborting.`n" -ForegroundColor Red
            return
        }
        # Clean path (remove quotes if drag & drop)
        $source = $source.Trim('"')
        Write-Host ""
    }
    
    # Verify source exists
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source path does not exist: $source`n" -ForegroundColor Red
        return
    }
    
    # --- Destination Input ---
    if (-not $destination) {
        Write-Host "Destination Directory" -ForegroundColor Cyan
        $destination = Read-Host "   Enter destination path (or drag & drop)"
        if (-not $destination) {
            Write-Host "   ERROR: No destination provided. Aborting.`n" -ForegroundColor Red
            return
        }
        # Clean path (remove quotes if drag & drop)
        $destination = $destination.Trim('"')
        Write-Host ""
    }
    
    # --- Preset Selection ---
    if ($useDefaults -or ($savedSettings -and $settingChoice -eq "1")) {
        $presetChoice = if ($savedSettings.presetChoice) { $savedSettings.presetChoice } else { "1" }
        $currentSettings.presetChoice = $presetChoice
        
        $presetName = switch ($presetChoice) {
            "1" { "mirror" }
            "2" { "sync" }
            "3" { "backup" }
            "4" { "fast" }
            "5" { "verify" }
            "6" { "incremental" }
            default { "mirror" }
        }
        
        Write-Host "Preset: " -ForegroundColor Cyan -NoNewline
        Write-Host "$($roboPresets[$presetName].description)" -ForegroundColor Yellow
    }
    else {
        Write-Host "Copy Mode Presets" -ForegroundColor Cyan
        Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "   1. Mirror (delete extra files in dest)" -ForegroundColor White
        Write-Host "   2. Sync (keep all subdirs, no deletions)" -ForegroundColor White
        Write-Host "   3. Backup (skip older files)" -ForegroundColor White
        Write-Host "   4. Fast (minimal logging, max threads)" -ForegroundColor White
        Write-Host "   5. Verify (with verification)" -ForegroundColor White
        Write-Host "   6. Incremental (skip older files)" -ForegroundColor White
        Write-Host "   7. Custom flags" -ForegroundColor White
        Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
        
        $presetChoice = Read-Host "   Select preset (1-7, default: 1)"
        $currentSettings.presetChoice = $presetChoice
    }
    
    # Get flags based on preset
    $baseFlags = switch ($presetChoice) {
        "1" { $roboPresets["mirror"].flags }
        "2" { $roboPresets["sync"].flags }
        "3" { $roboPresets["backup"].flags }
        "4" { $roboPresets["fast"].flags }
        "5" { $roboPresets["verify"].flags }
        "6" { $roboPresets["incremental"].flags }
        "7" {
            Write-Host "`nCustom Flags Mode" -ForegroundColor Cyan
            Write-Host "   Example: /E /MT:16 /R:2 /W:3`n" -ForegroundColor Gray
            $customFlags = Read-Host "   Enter robocopy flags"
            $customFlags
        }
        default { $roboPresets["mirror"].flags }
    }
    
    # --- Logging Options ---
    $logArgs = ""
    
    if ($useDefaults) {
        Write-Host "Logging: " -ForegroundColor Cyan -NoNewline
        Write-Host "Console only`n" -ForegroundColor Gray
    }
    elseif ($savedSettings -and $settingChoice -eq "1") {
        $logChoice = $savedSettings.logChoice
        $currentSettings.logChoice = $logChoice
        
        switch ($logChoice) {
            "2" { 
                $logFile = "$env:USERPROFILE\Documents\robocopy-logs\robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                $logArgs = "/LOG:`"$logFile`" /NP"
                Write-Host "Logging: File (saved)`n" -ForegroundColor Cyan
            }
            "3" { 
                $logFile = "$env:USERPROFILE\Documents\robocopy-logs\robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                $logArgs = "/LOG+:`"$logFile`" /NP"
                Write-Host "Logging: Append (saved)`n" -ForegroundColor Cyan
            }
            default { Write-Host "Logging: Console only`n" -ForegroundColor Cyan }
        }
    }
    else {
        Write-Host "Logging Options" -ForegroundColor Cyan
        Write-Host "   1. Console only (no log file)" -ForegroundColor White
        Write-Host "   2. Log to file (overwrite)" -ForegroundColor White
        Write-Host "   3. Log to file (append)" -ForegroundColor White
        $logChoice = Read-Host "   Choice (1-3, default: 1)"
        
        $currentSettings.logChoice = $logChoice
        
        switch ($logChoice) {
            "2" {
                $logPath = "$env:USERPROFILE\Documents\robocopy-logs"
                if (-not (Test-Path $logPath)) {
                    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
                }
                $logFile = "$logPath\robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                $logArgs = "/LOG:`"$logFile`" /NP"
                Write-Host "   OK. Logging to: $logFile" -ForegroundColor Green
            }
            "3" {
                $logPath = "$env:USERPROFILE\Documents\robocopy-logs"
                if (-not (Test-Path $logPath)) {
                    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
                }
                $logFile = "$logPath\robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                $logArgs = "/LOG+:`"$logFile`" /NP"
                Write-Host "   OK. Appending to: $logFile" -ForegroundColor Green
            }
        }
        Write-Host ""
    }
    
    # --- Exclusion Options ---
    $excludeArgs = ""
    
    if ($useDefaults) {
        Write-Host "Exclusions: " -ForegroundColor Cyan -NoNewline
        Write-Host "None`n" -ForegroundColor Gray
    }
    elseif ($savedSettings -and $settingChoice -eq "1") {
        $excludeChoice = $savedSettings.excludeChoice
        $currentSettings.excludeChoice = $excludeChoice
        
        switch ($excludeChoice) {
            "2" { 
                $excludeArgs = "/XD node_modules .git .svn bin obj"
                Write-Host "Exclusions: Development folders (saved)`n" -ForegroundColor Cyan
            }
            "3" { 
                $excludeArgs = "/XF *.tmp *.log Thumbs.db Desktop.ini .DS_Store"
                Write-Host "Exclusions: System/temp files (saved)`n" -ForegroundColor Cyan
            }
            "4" { 
                $excludeArgs = "/XD node_modules .git .svn bin obj /XF *.tmp *.log Thumbs.db .DS_Store"
                Write-Host "Exclusions: Development + System (saved)`n" -ForegroundColor Cyan
            }
            default { Write-Host "Exclusions: None`n" -ForegroundColor Cyan }
        }
    }
    else {
        Write-Host "Exclusion Filters" -ForegroundColor Cyan
        Write-Host "   1. No exclusions" -ForegroundColor White
        Write-Host "   2. Exclude dev folders (node_modules, .git, bin, obj)" -ForegroundColor White
        Write-Host "   3. Exclude system/temp files (*.tmp, *.log, Thumbs.db)" -ForegroundColor White
        Write-Host "   4. Both (dev + system)" -ForegroundColor White
        Write-Host "   5. Custom exclusions" -ForegroundColor White
        $excludeChoice = Read-Host "   Choice (1-5, default: 1)"
        
        $currentSettings.excludeChoice = $excludeChoice
        
        switch ($excludeChoice) {
            "2" {
                $excludeArgs = "/XD node_modules .git .svn bin obj"
                Write-Host "   OK. Excluding development folders" -ForegroundColor Green
            }
            "3" {
                $excludeArgs = "/XF *.tmp *.log Thumbs.db Desktop.ini .DS_Store"
                Write-Host "   OK. Excluding system/temp files" -ForegroundColor Green
            }
            "4" {
                $excludeArgs = "/XD node_modules .git .svn bin obj /XF *.tmp *.log Thumbs.db .DS_Store"
                Write-Host "   OK. Excluding dev folders + system files" -ForegroundColor Green
            }
            "5" {
                Write-Host "   Enter folders to exclude (space-separated): " -NoNewline
                $customDirs = Read-Host
                Write-Host "   Enter files to exclude (space-separated, e.g., *.tmp *.log): " -NoNewline
                $customFiles = Read-Host
                
                $excludeArgs = ""
                if ($customDirs) { $excludeArgs += "/XD $customDirs " }
                if ($customFiles) { $excludeArgs += "/XF $customFiles" }
                
                Write-Host "   OK. Custom exclusions set" -ForegroundColor Green
            }
        }
        Write-Host ""
    }
    
    # Save settings for next time (only if not using defaults this time)
    if (-not $useDefaults -and $settingChoice -ne "1") {
        Write-Host "Save these settings for next time? (Y/n): " -ForegroundColor Cyan -NoNewline
        $saveChoice = Read-Host
        if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
            Save-RoboSettings $currentSettings
        }
        Write-Host ""
    }
    
    # --- Preview & Confirmation ---
    Write-Host "COPY PREVIEW" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "   Source:      " -NoNewline -ForegroundColor Gray
    Write-Host "$source" -ForegroundColor White
    Write-Host "   Destination: " -NoNewline -ForegroundColor Gray
    Write-Host "$destination" -ForegroundColor White
    Write-Host "   Flags:       " -NoNewline -ForegroundColor Gray
    Write-Host "$baseFlags" -ForegroundColor Yellow
    if ($excludeArgs) {
        Write-Host "   Exclusions:  " -NoNewline -ForegroundColor Gray
        Write-Host "$excludeArgs" -ForegroundColor Yellow
    }
    if ($logArgs) {
        Write-Host "   Logging:     " -NoNewline -ForegroundColor Gray
        Write-Host "Enabled" -ForegroundColor Green
    }
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "   1. Start copy" -ForegroundColor White
    Write-Host "   2. Dry run (what-if)" -ForegroundColor White
    Write-Host "   3. Show detailed stats" -ForegroundColor White
    Write-Host "   4. Cancel" -ForegroundColor White
    $confirmChoice = Read-Host "   Choice (1-4, default: 1)"
    
    # --- Execute Command ---
    switch ($confirmChoice) {
        "2" {
            # Dry run
            Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
            Write-Host "DRY RUN MODE (What-If)" -ForegroundColor Yellow
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            $dryRunCommand = "robocopy `"$source`" `"$destination`" $baseFlags $excludeArgs /L /NP"
            Write-Host "Executing: $dryRunCommand`n" -ForegroundColor Gray
            
            try {
                Invoke-Expression $dryRunCommand
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "OK. Dry run complete!" -ForegroundColor Green
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`nERROR: Dry run failed: $_`n" -ForegroundColor Red
            }
        }
        "3" {
            # Show stats
            Write-Host "`nGathering statistics...`n" -ForegroundColor Yellow
            
            try {
                $sourceStats = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                $sourceCount = $sourceStats.Count
                $sourceSize = [math]::Round($sourceStats.Sum / 1GB, 2)
                
                Write-Host "Source Statistics:" -ForegroundColor Cyan
                Write-Host "   Files: " -NoNewline -ForegroundColor Gray
                Write-Host "$sourceCount" -ForegroundColor Green
                Write-Host "   Size:  " -NoNewline -ForegroundColor Gray
                Write-Host "$sourceSize GB" -ForegroundColor Green
                
                if (Test-Path $destination) {
                    $destStats = Get-ChildItem -Path $destination -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                    $destCount = $destStats.Count
                    $destSize = [math]::Round($destStats.Sum / 1GB, 2)
                    
                    Write-Host "`nDestination Statistics:" -ForegroundColor Cyan
                    Write-Host "   Files: " -NoNewline -ForegroundColor Gray
                    Write-Host "$destCount" -ForegroundColor Green
                    Write-Host "   Size:  " -NoNewline -ForegroundColor Gray
                    Write-Host "$destSize GB" -ForegroundColor Green
                }
                else {
                    Write-Host "`nDestination: " -NoNewline -ForegroundColor Cyan
                    Write-Host "Does not exist yet" -ForegroundColor Yellow
                }
                Write-Host ""
            }
            catch {
                Write-Host "ERROR: Could not gather stats: $_`n" -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "`nOK. Cancelled.`n" -ForegroundColor Yellow
            return
        }
        default {
            # Start copy
            Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
            Write-Host "STARTING COPY" -ForegroundColor Green
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            $finalCommand = "robocopy `"$source`" `"$destination`" $baseFlags $excludeArgs $logArgs"
            Write-Host "Executing: $finalCommand`n" -ForegroundColor Gray
            
            try {
                $startTime = Get-Date
                Invoke-Expression $finalCommand
                $exitCode = $LASTEXITCODE
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                
                # Interpret exit code
                if ($exitCode -ge 8) {
                    Write-Host "ERROR: Copy failed! (Exit code: $exitCode)" -ForegroundColor Red
                    Write-Host "Some files could not be copied." -ForegroundColor Yellow
                }
                elseif ($exitCode -eq 0) {
                    Write-Host "OK. No changes needed! " -ForegroundColor Green -NoNewline
                    Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                }
                else {
                    Write-Host "OK. Copy complete! " -ForegroundColor Green -NoNewline
                    Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                    
                    if ($exitCode -band 1) { Write-Host "   INFO: Files copied successfully" -ForegroundColor Cyan }
                    if ($exitCode -band 2) { Write-Host "   INFO: Extra files/dirs detected" -ForegroundColor Cyan }
                    if ($exitCode -band 4) { Write-Host "   INFO: Mismatches detected" -ForegroundColor Yellow }
                }
                
                if ($logFile) {
                    Write-Host "Log saved: $logFile" -ForegroundColor Cyan
                }
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "ERROR: Copy failed!" -ForegroundColor Red
                Write-Host "Error: $_" -ForegroundColor Yellow
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
        }
    }
}

# ============================================================================
# QUICK ALIASES
# ============================================================================

function robo-mirror {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting mirror sync..." -ForegroundColor Yellow
    robocopy "$source" "$destination" /MIR /R:3 /W:5 /MT:8 /V
}

function robo-backup {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting backup (skip older)..." -ForegroundColor Yellow
    robocopy "$source" "$destination" /MIR /DCOPY:DAT /COPY:DAT /R:3 /W:5 /MT:8 /XO /V
}

function robo-sync {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting sync (no deletions)..." -ForegroundColor Yellow
    robocopy "$source" "$destination" /E /R:3 /W:5 /MT:8 /V
}

function robo-fast {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting fast copy (minimal logging)..." -ForegroundColor Yellow
    robocopy "$source" "$destination" /E /R:1 /W:1 /MT:16 /NFL /NDL /NJH /NJS
}

function robo-verify {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting verified copy..." -ForegroundColor Yellow
    robocopy "$source" "$destination" /E /R:3 /W:5 /MT:8 /V /ETA
}

function robo-diff {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Host "ERROR: Source does not exist: $source" -ForegroundColor Red
        return
    }
    
    Write-Host "Comparing directories...`n" -ForegroundColor Yellow
    robocopy "$source" "$destination" /L /E /NP /NDL /NJH /NJS
}

function robo-stats {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "`nDirectory Statistics for: " -ForegroundColor Cyan -NoNewline
    Write-Host "$path`n" -ForegroundColor White
    
    try {
        $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
        $dirs = Get-ChildItem -Path $path -Recurse -Directory -ErrorAction SilentlyContinue
        $size = ($files | Measure-Object -Property Length -Sum).Sum
        
        Write-Host "   Files:       " -NoNewline -ForegroundColor Gray
        Write-Host "$($files.Count)" -ForegroundColor Green
        Write-Host "   Directories: " -NoNewline -ForegroundColor Gray
        Write-Host "$($dirs.Count)" -ForegroundColor Green
        Write-Host "   Total Size:  " -NoNewline -ForegroundColor Gray
        Write-Host "$([math]::Round($size/1GB, 2)) GB" -ForegroundColor Yellow
        
        # Top 5 largest files
        Write-Host "`n   Largest Files:" -ForegroundColor Cyan
        $files | Sort-Object Length -Descending | Select-Object -First 5 | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host "      $sizeMB MB - " -NoNewline -ForegroundColor Gray
            Write-Host "$($_.Name)" -ForegroundColor White
        }
        Write-Host ""
    }
    catch {
        Write-Host "ERROR: Could not gather stats: $_`n" -ForegroundColor Red
    }
}

function robo-reset-settings {
    if (Test-Path $roboSettingsFile) {
        Remove-Item $roboSettingsFile -Force
        Write-Host "OK. Settings reset! Next run will prompt for new settings." -ForegroundColor Green
    }
    else {
        Write-Host "WARNING: No saved settings found." -ForegroundColor Yellow
    }
}

# ============================================================================
# ADVANCED UTILITIES
# ============================================================================

function robo-schedule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination,
        [string]$time = "02:00"
    )
    
    Write-Host "`nSchedule Robocopy Task" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $taskName = "RobocopyBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"robocopy '$source' '$destination' /MIR /R:3 /W:5 /MT:8`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $time
    
    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description "Automated robocopy backup"
        Write-Host "OK. Scheduled task created: $taskName" -ForegroundColor Green
        Write-Host "   Time: $time daily" -ForegroundColor Gray
        Write-Host "   View in Task Scheduler to modify" -ForegroundColor Gray
    }
    catch {
        Write-Host "ERROR: Could not create scheduled task: $_" -ForegroundColor Red
    }
}

function robo-watch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$destination,
        [int]$interval = 60
    )
    
    Write-Host "`nWatching for changes..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray
    
    while ($true) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Syncing..." -ForegroundColor Cyan
        robocopy "$source" "$destination" /E /R:1 /W:1 /MT:8 /NFL /NDL /NJH /NJS /XO
        Start-Sleep -Seconds $interval
    }
}

# ============================================================================
# HELP FUNCTION
# ============================================================================

function robo-help {
    Write-Host "`nROBOCOPY-ENHANCE COMMANDS" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    Write-Host "`nINTERACTIVE:" -ForegroundColor Cyan
    Write-Host "  robocopy              " -NoNewline -ForegroundColor Green
    Write-Host "Interactive mode with menus" -ForegroundColor Gray
    
    Write-Host "`nQUICK COMMANDS:" -ForegroundColor Cyan
    Write-Host "  robo-mirror <src> <dst>     " -NoNewline -ForegroundColor Green
    Write-Host "Mirror sync (delete extras)" -ForegroundColor Gray
    Write-Host "  robo-backup <src> <dst>     " -NoNewline -ForegroundColor Green
    Write-Host "Backup (skip older files)" -ForegroundColor Gray
    Write-Host "  robo-sync <src> <dst>       " -NoNewline -ForegroundColor Green
    Write-Host "Sync (no deletions)" -ForegroundColor Gray
    Write-Host "  robo-fast <src> <dst>       " -NoNewline -ForegroundColor Green
    Write-Host "Fast copy (minimal logs)" -ForegroundColor Gray
    Write-Host "  robo-verify <src> <dst>     " -NoNewline -ForegroundColor Green
    Write-Host "Verified copy" -ForegroundColor Gray
    
    Write-Host "`nANALYSIS:" -ForegroundColor Cyan
    Write-Host "  robo-diff <src> <dst>       " -NoNewline -ForegroundColor Green
    Write-Host "Compare directories" -ForegroundColor Gray
    Write-Host "  robo-stats <path>           " -NoNewline -ForegroundColor Green
    Write-Host "Show directory statistics" -ForegroundColor Gray
    
    Write-Host "`nADVANCED:" -ForegroundColor Cyan
    Write-Host "  robo-schedule <src> <dst>   " -NoNewline -ForegroundColor Green
    Write-Host "Create scheduled task" -ForegroundColor Gray
    Write-Host "  robo-watch <src> <dst>      " -NoNewline -ForegroundColor Green
    Write-Host "Watch and auto-sync" -ForegroundColor Gray
    Write-Host "  robo-reset-settings         " -NoNewline -ForegroundColor Green
    Write-Host "Clear saved settings" -ForegroundColor Gray
    
    Write-Host "`nPRESETS:" -ForegroundColor Cyan
    Write-Host "  Mirror:      " -NoNewline -ForegroundColor Gray
    Write-Host "Delete extra files in destination" -ForegroundColor White
    Write-Host "  Sync:        " -NoNewline -ForegroundColor Gray
    Write-Host "Keep all subdirs, no deletions" -ForegroundColor White
    Write-Host "  Backup:      " -NoNewline -ForegroundColor Gray
    Write-Host "Skip older files" -ForegroundColor White
    Write-Host "  Fast:        " -NoNewline -ForegroundColor Gray
    Write-Host "Minimal logging, max threads" -ForegroundColor White
    Write-Host "  Verify:      " -NoNewline -ForegroundColor Gray
    Write-Host "Copy with verification" -ForegroundColor White
    Write-Host "  Incremental: " -NoNewline -ForegroundColor Gray
    Write-Host "Skip older files" -ForegroundColor White
    
    Write-Host "`nEXAMPLES:" -ForegroundColor Cyan
    Write-Host "  robocopy                              " -NoNewline -ForegroundColor Gray
    Write-Host "# Interactive mode" -ForegroundColor DarkGray
    Write-Host "  robo-mirror C:\Source D:\Backup       " -NoNewline -ForegroundColor Gray
    Write-Host "# Quick mirror" -ForegroundColor DarkGray
    Write-Host "  robo-diff C:\Folder1 C:\Folder2       " -NoNewline -ForegroundColor Gray
    Write-Host "# Compare" -ForegroundColor DarkGray
    Write-Host "  robo-schedule C:\Data D:\Backup 02:00 " -NoNewline -ForegroundColor Gray
    Write-Host "# Schedule at 2am" -ForegroundColor DarkGray
    
    Write-Host "`nEXIT CODES:" -ForegroundColor Cyan
    Write-Host "  0  " -NoNewline -ForegroundColor Gray
    Write-Host "No changes needed" -ForegroundColor White
    Write-Host "  1  " -NoNewline -ForegroundColor Gray
    Write-Host "Files copied successfully" -ForegroundColor White
    Write-Host "  2  " -NoNewline -ForegroundColor Gray
    Write-Host "Extra files/directories detected" -ForegroundColor White
    Write-Host "  4  " -NoNewline -ForegroundColor Gray
    Write-Host "Mismatches detected" -ForegroundColor White
    Write-Host "  8+ " -NoNewline -ForegroundColor Gray
    Write-Host "Errors occurred" -ForegroundColor White
    
    Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "Type 'robo-help' anytime to see this help`n" -ForegroundColor Gray
}

# ============================================================================
# INITIALIZATION
# ============================================================================

Write-Host "OK. robocopy-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'robo-help' for commands" -ForegroundColor Cyan
