# Sys-Info.ps1
# Part of TheSecretJuice - Sys Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# System Information & Performance
# ==========================================================

function sys {
    <#
    .SYNOPSIS
    Complete system information and performance snapshot with formatted colorful output + gauges.      
    .PARAMETER Export
    Path to export the report (txt).
    .PARAMETER Quick
    Show only essential info.
    .PARAMETER TopN
    Number of top CPU processes to display (default: 5).
    .PARAMETER NoEmoji
    Disable emojis for plain text environments.
    .PARAMETER ColorScheme
    Primary highlight color (default: Cyan).
    #>
    param(
        [string]$Export,
        [switch]$Quick,
        [int]$TopN = 5,
        [switch]$NoEmoji,
        [ValidateSet("Cyan", "Green", "Yellow", "Magenta", "Blue", "White")]
        [string]$ColorScheme = "Cyan"
    )

    Write-JuiceBanner -Title "System Information"

    function Add-Emoji {
        param([string]$text, [string]$emoji)
        if ($NoEmoji) { return $text }
        else { return "$emoji $text" }
    }

    function Get-Gauge {
        param(
            [Parameter(Mandatory)][double]$Percent,
            [int]$Length = 10
        )
        $filled = [math]::Round(($Percent / 100) * $Length)
        $empty = $Length - $filled
        $bar = ('█' * $filled) + ('░' * $empty)
        return "$bar $Percent%"
    }

    if ($Quick) {
        # Quick summary
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $memUsed = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
        $cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        $disk = Get-PSDrive C
        $diskUsed = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 1)

        Write-Color "`n$(Add-Emoji 'Quick System Status' '⚡')" Yellow
        Write-Color "OS: $($os.Caption)" White
        Write-Color "CPU: $($cpu.Name)" White
        Write-Color ("CPU Load: " + (Get-Gauge $cpuLoad)) ($cpuLoad -gt 70 ? "Red" : "Green")
        Write-Color ("RAM: " + (Get-Gauge $memUsed) + " of $([math]::Round($os.TotalVisibleMemorySize/1MB,1))GB") ($memUsed -gt 80 ? "Red" : "Green")
        Write-Color ("Disk C: " + (Get-Gauge $diskUsed)) ($diskUsed -gt 80 ? "Red" : "Green")
        return
    }

    # Full system information
    $os = Get-ComputerInfo | Select-Object OsName, OsArchitecture, WindowsVersion, CsName, WindowsBuildLabEx
    $cpu = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
    $ramOs = Get-CimInstance Win32_OperatingSystem
    $ram = [pscustomobject]@{
        TotalGB      = [math]::Round($ramOs.TotalVisibleMemorySize / 1MB, 2)
        FreeGB       = [math]::Round($ramOs.FreePhysicalMemory / 1MB, 2)
        UsedGB       = [math]::Round(($ramOs.TotalVisibleMemorySize - $ramOs.FreePhysicalMemory) / 1MB, 2)
        UsagePercent = [math]::Round((($ramOs.TotalVisibleMemorySize - $ramOs.FreePhysicalMemory) / $ramOs.TotalVisibleMemorySize) * 100, 1)
    }
    $disk = Get-PSDrive -PSProvider FileSystem |
    Select-Object Name,
    @{n = "TotalGB"; e = { [math]::Round(($_.Used + $_.Free) / 1GB, 2) } },
    @{n = "FreeGB"; e = { [math]::Round($_.Free / 1GB, 2) } },
    @{n = "UsedGB"; e = { [math]::Round(($_.Used / 1GB), 2) } },
    @{n = "UsagePercent"; e = { [math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 1) } }

    # Performance metrics
    $cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $processCount = (Get-Process).Count
    $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First $TopN Name, CPU, @{n = "MemoryMB"; e = { [math]::Round($_.WorkingSet / 1MB, 1) } }

    # Display everything
    Write-Color "`n$(Add-Emoji 'SYSTEM INFORMATION' '🖥️')" Yellow
    Write-Color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" DarkGray    

    Write-Color "`n$(Add-Emoji 'Operating System' '📋')" $ColorScheme
    $os | Format-List | Out-String | Write-Host

    Write-Color "$(Add-Emoji 'Processor' '⚙️')" $ColorScheme
    $cpu | Format-List | Out-String | Write-Host
    Write-Color ("Current Load: " + (Get-Gauge $cpuLoad)) ($cpuLoad -gt 70 ? "Red" : "Green")

    Write-Color "`n$(Add-Emoji 'Memory' '💾')" $ColorScheme
    $ram | Format-Table -AutoSize | Out-String | Write-Host
    Write-Color ("Usage: " + (Get-Gauge $ram.UsagePercent)) ($ram.UsagePercent -gt 80 ? "Red" : "Green")

    Write-Color "$(Add-Emoji 'Storage' '💿')" $ColorScheme
    $disk | Format-Table -AutoSize | Out-String | Write-Host
    foreach ($d in $disk) {
        Write-Color ("Drive $($d.Name): " + (Get-Gauge $d.UsagePercent)) ($d.UsagePercent -gt 80 ? "Red" : "Green")
    }

    Write-Color "$(Add-Emoji 'Performance' '🔥')" $ColorScheme
    Write-Host "Running Processes: $processCount"
    Write-Host "`nTop $TopN CPU Consuming Processes:"
    $topProcesses | Format-Table -AutoSize | Out-String | Write-Host

    # Export if requested
    if ($Export) {
        @"
=== System Information Report ===
Generated: $(Get-Date)

[Operating System]
$($os | Format-List | Out-String)

[Processor]
$($cpu | Format-List | Out-String)
Current Load: $([math]::Round($cpuLoad,1))%

[Memory]
$($ram | Format-Table | Out-String)

[Storage]
$($disk | Format-Table | Out-String)

[Performance]
Running Processes: $processCount
Top $TopN Processes:
$($topProcesses | Format-Table | Out-String)
"@ | Out-File $Export -Encoding UTF8
        Write-Color "`n📄 Exported to: $Export" Green
    }
}
