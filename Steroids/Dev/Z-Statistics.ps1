# Z-Statistics.ps1
# Part of TheSecretJuice - Dev Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ╭─────────────────────────────────────────────────────────────────────────────╮
# PROFILE STATISTICS AND INFORMATION (Optimized)
# ╰─────────────────────────────────────────────────────────────────────────────╯

# Get profile loading performance (use $__ProfileStart from profile)
$profileLoadTime = if ($__ProfileStart) {
    [math]::Round(((Get-Date) - $__ProfileStart).TotalMilliseconds)
} else { $null }

# Cache OS info (single CIM call for performance)
$osData = try { Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue } catch { $null }  

# Detect available package managers (fast check using Get-Command cache)
$packageManagers = @()
@('scoop', 'choco', 'winget', 'npm', 'pip') | ForEach-Object {
    if (Get-Command $_ -ErrorAction SilentlyContinue) {
        $packageManagers += $_.ToUpper()
    }
}
if ($packageManagers.Count -eq 0) { $packageManagers += "None" }

# Get system information
$psVersion = $PSVersionTable.PSVersion.ToString()
$osInfo = if ($osData) { "$($osData.Caption) ($($osData.Version))" } else { "Windows" }

# Count custom functions (defined in this session, not from modules)
$totalFunctions = (Get-Command -CommandType Function | Where-Object {
    -not $_.Source -and
    $_.Name -notmatch '^(prompt|TabExpansion|__Log|Import-ModuleSafe|cd|more|oss|pause|Clear-Host)' -and
    $_.Name -notmatch '^[A-Z]:' -and
    $_.Name -notlike '*:*'
}).Count

# Count custom aliases (non-built-in)
$defaultAliases = @('foreach','where','sort','tee','measure','select','group','compare',
    'ft','fl','fw','gm','gc','gl','gp','gs','gv','gy','ii','iwr','ls','ps','pwd','r',
    'rm','rmdir','echo','cls','chdir','copy','del','dir','erase','move','ren','set','type',
    'cat','cd','clear','cp','diff','h','history','kill','lp','man','md','mi','mount',
    'mv','ni','nv','ogv','oh','popd','pushd','ri','rv','rvpa','sajb','sasnp','sc','si',
    'sl','sleep','sls','sort','sp','spjb','sv','swmi','tee','write')
$totalAliases = (Get-Alias | Where-Object { $_.Name -notin $defaultAliases }).Count

# Get memory usage
$memoryInfo = if ($osData) {
    $freeGB = [math]::Round($osData.FreePhysicalMemory / 1MB, 1)
    $totalGB = [math]::Round($osData.TotalVisibleMemorySize / 1MB, 1)
    $usedPercent = [math]::Round((($totalGB - $freeGB) / $totalGB) * 100)
    "$freeGB GB free of $totalGB GB ($usedPercent% used)"
} else { "N/A" }

# ╭─────────────────────────────────────────────────────────────────────────────╮
# DISPLAY SECTION
# ╰─────────────────────────────────────────────────────────────────────────────╯

function Write-DashLine($left, $text, $color = "White", $width = 80) {
    Write-Host "║   $left" -NoNewline -ForegroundColor DarkCyan
    Write-Host $text -NoNewline -ForegroundColor $color
    $pad = $width - 4 - $left.Length - $text.Length
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host "║" -ForegroundColor DarkCyan
}

Write-JuiceBanner -Title "Profile Statistics"

# System Information
Write-Host "║ " -NoNewline -ForegroundColor DarkCyan
Write-Host "SYSTEM INFO" -NoNewline -ForegroundColor Yellow
Write-Host (" " * 67) -NoNewline
Write-Host "║" -ForegroundColor DarkCyan

Write-DashLine "PowerShell: " $psVersion "White"
$osDisplay = if ($osInfo.Length -gt 55) { $osInfo.Substring(0, 55) + "..." } else { $osInfo }
Write-DashLine "OS: " $osDisplay "White"
Write-DashLine "Memory: " $memoryInfo "White"

Write-Host "╠─────────────────────────────────────────────────────────────────────────────╣" -ForegroundColor DarkCyan   

# Profile Statistics
Write-Host "║ " -NoNewline -ForegroundColor DarkCyan
Write-Host "PROFILE STATISTICS" -NoNewline -ForegroundColor Yellow
Write-Host (" " * 60) -NoNewline
Write-Host "║" -ForegroundColor DarkCyan

Write-DashLine "Custom Functions: " $totalFunctions.ToString() "Green"
Write-DashLine "Custom Aliases: " $totalAliases.ToString() "Green"
Write-DashLine "Package Managers: " ($packageManagers -join ", ") "Green"

$loadColor = if ($profileLoadTime -and $profileLoadTime -lt 500) { "Green" }
             elseif ($profileLoadTime -and $profileLoadTime -lt 1000) { "Yellow" }
             elseif ($profileLoadTime) { "Red" } else { "Gray" }
$loadText = if ($profileLoadTime) { "${profileLoadTime}ms" } else { "N/A" }
Write-DashLine "Load Time: " $loadText $loadColor

Write-Host "╠─────────────────────────────────────────────────────────────────────────────╣" -ForegroundColor DarkCyan   

# Quick Commands Reference
Write-Host "║ " -NoNewline -ForegroundColor DarkCyan
Write-Host "QUICK COMMANDS" -NoNewline -ForegroundColor Yellow
Write-Host (" " * 64) -NoNewline
Write-Host "║" -ForegroundColor DarkCyan

$quickCommands = @(
    @("help", "Show available commands"),
    @("sys", "System information and stats"),
    @("optimize", "Quick system cleanup"),
    @("update", "Update all package managers"),
    @("tools", "Check dev tools"),
    @("restart", "Restart terminal")
)

foreach ($cmd in $quickCommands) {
    Write-Host "║   " -NoNewline -ForegroundColor DarkCyan
    Write-Host $cmd[0].PadRight(10) -NoNewline -ForegroundColor Cyan
    Write-Host "- " -NoNewline -ForegroundColor DarkGray
    Write-Host $cmd[1] -NoNewline -ForegroundColor White
    $pad = 64 - $cmd[1].Length
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host "║" -ForegroundColor DarkCyan
}

Write-Host "╚─────────────────────────────────────────────────────────────────────────────╝" -ForegroundColor DarkCyan    
Write-Host ""
