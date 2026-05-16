# Sys-Maintanance.ps1
# Part of TheSecretJuice - Sys Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# System Maintenance
# ==========================================================
function Optimize {
    <#
    .SYNOPSIS
    Complete system optimization and cleanup
    .DESCRIPTION
    Performs comprehensive cleanup, service optimization, memory management, network tuning, and disk optimization
    .PARAMETER Preview
    Show actions without executing them
    .PARAMETER Quick
    Skip disk optimization and deep cleaning for faster execution
    .EXAMPLE
    Optimize
    Run full system optimization
    .EXAMPLE
    Optimize -Preview
    See what would be done without making changes
    .EXAMPLE
    Optimize -Quick
    Fast optimization without disk defrag
    #>
    param(
        [switch]$Preview,
        [switch]$Quick
    )

    Write-JuiceBanner -Title "System Optimization"

    $startTime = Get-Date
    $before = (Get-PSDrive C -ErrorAction SilentlyContinue).Free
    if (-not $before) { $before = 0 }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 1: COMPREHENSIVE CLEANUP
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n🧹 Step 1: System Cleanup" Cyan
    Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

    $tempDirs = @(
        "$env:TEMP",
        "C:\Windows\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\WebCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files",
        "$env:WINDIR\SoftwareDistribution\Download",
        "$env:WINDIR\Logs",
        "$env:LOCALAPPDATA\CrashDumps"
    )

    # Add browser cache directories
    $browserCaches = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\entries",
        "$env:LOCALAPPDATA\Opera Software\Opera Stable\Cache"
    )

    foreach ($cache in $browserCaches) {
        if ($cache -like "*\*\*") {
            # Handle wildcard paths like Firefox
            $basePath = Split-Path (Split-Path $cache) -Parent
            if (Test-Path $basePath -ErrorAction SilentlyContinue) {
                $foundPaths = Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue | 
                ForEach-Object { Join-Path $_.FullName (Split-Path $cache -Leaf) }
                $tempDirs += $foundPaths
            }
        }
        elseif (Test-Path (Split-Path $cache -Parent) -ErrorAction SilentlyContinue) {
            $tempDirs += $cache
        }
    }

    $totalSize = 0
    $fileCount = 0

    foreach ($dir in $tempDirs) {
        if (Test-Path $dir -ErrorAction SilentlyContinue) {
            try {
                $items = Get-ChildItem -Path $dir -Recurse -Force -ErrorAction SilentlyContinue |      
                Where-Object { -not $_.PSIsContainer }

                if ($items) {
                    $size = ($items | Measure-Object Length -Sum -ErrorAction SilentlyContinue).Sum    
                    if (-not $size) { $size = 0 }
                    $count = $items.Count
                    $totalSize += $size
                    $fileCount += $count
                    $sizeMB = [math]::Round($size / 1MB, 2)

                    if ($Preview) {
                        Write-Color "  🔍 Would clean: $(Split-Path $dir -Leaf) ($count files, $sizeMB MB)" Cyan
                    }
                    else {
                        try {
                            $items | Remove-Item -Force -ErrorAction Stop
                            Write-Color "  ✅ Cleaned $(Split-Path $dir -Leaf) ($count files, $sizeMB MB)" Green
                        }
                        catch {
                            Write-Color "  ⚠️ Partial clean of $(Split-Path $dir -Leaf): $($_.Exception.Message)" Yellow
                        }
                    }
                }
            }
            catch {
                Write-Color "  ⚠️ Could not access $dir" Yellow
            }
        }
    }

    # Recycle Bin cleanup
    if ($Preview) {
        Write-Color "  🗑️ Would empty Recycle Bin" Cyan
    }
    else {
        try {
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            if ($recycleBin.Items().Count -gt 0) {
                $recycleBin.Self.InvokeVerb("Empty Recycle Bin")
                Write-Color "  ✅ Recycle Bin emptied" Green
            }
            else {
                Write-Color "  ✅ Recycle Bin already empty" Green
            }
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
        catch {
            try {
                Clear-RecycleBin -Force -ErrorAction Stop -Confirm:$false
                Write-Color "  ✅ Recycle Bin emptied" Green
            }
            catch {
                Write-Color "  ⚠️ Could not empty Recycle Bin" Yellow
            }
        }
    }

    # Windows Update cleanup and DISM operations
    if (-not $Quick) {
        if ($Preview) {
            Write-Color "  🔧 Would run Windows component cleanup" Cyan
        }
        else {
            try {
                Write-Color "  🔧 Running component store cleanup..." Yellow
                $dismProcess = Start-Process -FilePath "DISM.exe" -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup", "/ResetBase" -Wait -NoNewWindow -PassThru
                if ($dismProcess.ExitCode -eq 0) {
                    Write-Color "  ✅ Windows component store cleaned" Green
                }
                else {
                    Write-Color "  ⚠️ Component cleanup completed with warnings" Yellow
                }
            }
            catch {
                Write-Color "  ⚠️ Could not run component cleanup" Yellow
            }
        }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 2: SERVICE OPTIMIZATION
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n⚙️ Step 2: Service Optimization" Cyan
    Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

    $servicesToOptimize = @{
        'Fax'                = 'Fax Service'
        'Spooler'            = 'Print Spooler (if not needed)'
        'TabletInputService' = 'Tablet PC Input Service'
        'WSearch'            = 'Windows Search (temporary)'
        'Themes'             = 'Themes Service'
        'SysMain'            = 'SuperFetch/SysMain'
        'WbioSrvc'           = 'Windows Biometric Service'
        'TapiSrv'            = 'Telephony Service'
        'FontCache'          = 'Windows Font Cache Service'
    }

    foreach ($svcName in $servicesToOptimize.Keys) {
        try {
            $service = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq 'Running') {
                if ($Preview) {
                    Write-Color "  🔄 Would stop $($servicesToOptimize[$svcName])" Cyan
                }
                else {
                    try {
                        Stop-Service -Name $svcName -Force -ErrorAction Stop
                        Write-Color "  ✅ Stopped $($servicesToOptimize[$svcName])" Green
                    }
                    catch {
                        Write-Color "  ⚠️ Could not stop $($servicesToOptimize[$svcName])" Yellow   
                    }
                }
            }
        }
        catch {
            continue
        }
    }

    # Start essential services that should be running
    $essentialServices = @('Winmgmt', 'RpcSs', 'DcomLaunch', 'PlugPlay')
    foreach ($svc in $essentialServices) {
        try {
            $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($service -and $service.Status -ne 'Running') {
                if (-not $Preview) {
                    Start-Service -Name $svc -ErrorAction SilentlyContinue
                }
            }
        }
        catch { continue }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 3: MEMORY OPTIMIZATION
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n🧠 Step 3: Memory Optimization" Cyan
    Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

    if ($Preview) {
        Write-Color "  🔄 Would optimize memory and clear working sets" Cyan
    }
    else {
        try {
            # Aggressive garbage collection
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
            [System.GC]::Collect()

            # Clear working sets
            $processes = Get-Process | Where-Object { $_.WorkingSet -gt 50MB }
            $clearedCount = 0
            foreach ($proc in $processes) {
                try {
                    $proc.WorkingSet = -1
                    $clearedCount++
                }
                catch { continue }
            }

            Write-Color "  ✅ Memory optimized, cleared $clearedCount process working sets" Green     
        }
        catch {
            Write-Color "  ⚠️ Memory optimization partially failed" Yellow
        }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 4: NETWORK OPTIMIZATION
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n🌐 Step 4: Network Optimization" Cyan
    Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

    if ($Preview) {
        Write-Color "  🔄 Would flush DNS and optimize TCP settings" Cyan
    }
    else {
        try {
            # DNS flush
            $null = ipconfig /flushdns
            Write-Color "  ✅ DNS cache flushed" Green

            # TCP optimizations
            $tcpCommands = @(
                "netsh int tcp set global autotuninglevel=normal",
                "netsh int tcp set global chimney=enabled",
                "netsh int tcp set global rss=enabled",
                "netsh int tcp set global netdma=enabled",
                "netsh int tcp set global dca=enabled"
            )

            foreach ($cmd in $tcpCommands) {
                try { Invoke-Expression $cmd | Out-Null } catch { continue }
            }
            Write-Color "  ✅ TCP stack optimized" Green

            # Winsock reset (careful operation)
            try {
                $null = netsh winsock reset catalog
                Write-Color "  ✅ Winsock catalog reset" Green
            }
            catch {
                Write-Color "  ⚠️ Could not reset Winsock catalog" Yellow
            }
        }
        catch {
            Write-Color "  ⚠️ Network optimization failed" Yellow
        }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 5: DISK OPTIMIZATION
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    if (-not $Quick) {
        Write-Color "`n💾 Step 5: Disk Optimization" Cyan
        Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

        if ($Preview) {
            Write-Color "  🔄 Would optimize available drives" Cyan
        }
        else {
            try {
                $drives = Get-Volume | Where-Object {
                    $_.DriveLetter -and
                    $_.DriveType -eq 'Fixed' -and
                    $_.FileSystemType -in @('NTFS', 'ReFS') -and
                    $_.Size -gt 1GB
                }

                foreach ($drive in $drives) {
                    try {
                        Write-Color "  🔄 Optimizing drive $($drive.DriveLetter):..." Yellow
                        Optimize-Volume -DriveLetter $drive.DriveLetter -Analyze -Defrag -Verbose:$false -ErrorAction Stop
                        Write-Color "  ✅ Drive $($drive.DriveLetter): optimized" Green
                    }
                    catch {
                        Write-Color "  ⚠️ Could not optimize drive $($drive.DriveLetter):" Yellow   
                    }
                }
            }
            catch {
                Write-Color "  ⚠️ Disk optimization failed" Yellow
            }
        }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # STEP 6: REGISTRY OPTIMIZATION (Safe operations only)
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n🔧 Step 6: System Tweaks" Cyan
    Write-Color "─────────────────────────────────────────────────────────────────────────" DarkGray

    if ($Preview) {
        Write-Color "  🔄 Would apply performance registry tweaks" Cyan
    }
    else {
        try {
            # Visual effects for performance
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"        
            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue
            }

            # Disable search indexing on C: drive temporarily
            try {
                $service = Get-Service "WSearch" -ErrorAction SilentlyContinue
                if ($service -and $service.Status -eq 'Running') {
                    Restart-Service "WSearch" -ErrorAction SilentlyContinue
                }
            }
            catch { }

            Write-Color "  ✅ Performance tweaks applied" Green
        }
        catch {
            Write-Color "  ⚠️ Could not apply all system tweaks" Yellow
        }
    }

    # ╭─────────────────────────────────────────────────────────────────────────────╮
    # FINAL SUMMARY
    # ╰─────────────────────────────────────────────────────────────────────────────╯
    Write-Color "`n📊 Optimization Summary" Yellow
    Write-Color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" DarkGray

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    $after = (Get-PSDrive C -ErrorAction SilentlyContinue).Free
    if (-not $after) { $after = $before }
    $saved = [math]::Round(($after - $before) / 1MB, 2)
    $totalMB = [math]::Round($totalSize / 1MB, 2)

    try {
        $memInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $freeMem = [math]::Round($memInfo.FreePhysicalMemory / 1MB, 2)
        $totalMem = [math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 2)
        $diskFree = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
        $diskTotal = [math]::Round((Get-PSDrive C).Used / 1GB + $diskFree, 2)

        Write-Color "⏱️  Duration: $([math]::Round($duration, 1)) seconds" White
        Write-Color "📂 Files processed: $fileCount files ($totalMB MB $(if($Preview){'identified'}else{'cleaned'}))" White

        if (-not $Preview) {
            if ($saved -gt 0) {
                Write-Color "💾 Disk space recovered: $saved MB" Green
            }
            Write-Color "🧠 Memory: $freeMem MB free of $totalMem MB ($([math]::Round(($freeMem/$totalMem)*100,1))% free)" White
            Write-Color "💿 Disk C:: $diskFree GB free of $diskTotal GB ($([math]::Round(($diskFree/$diskTotal)*100,1))% free)" White
        }
    }
    catch {
        Write-Color "⏱️  Duration: $([math]::Round($duration, 1)) seconds" White
        Write-Color "📂 Files: $fileCount processed ($totalMB MB)" White
    }

    if ($Preview) {
        Write-Color "`n🔍 This was a preview. Run 'Optimize' to execute changes." Yellow
    }
    else {
        Write-Color "`n✨ Complete system optimization finished!" Green
        Write-Color "💡 Tip: Restart your computer to fully benefit from all optimizations." Cyan    
    }
}
