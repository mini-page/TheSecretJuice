# Net-Works.ps1
# Part of TheSecretJuice - Net Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ==========================================================
# Network Tools
# ==========================================================

function net {
    <#
    .SYNOPSIS
    Complete network information and diagnostics
    .PARAMETER Public
    Show public IP address
    .PARAMETER Test
    Test connectivity to common sites
    .PARAMETER Flush
    Flush DNS cache
    .PARAMETER Ping
    Ping a specific host
    .PARAMETER Trace
    Run traceroute on a host
    .PARAMETER Dns
    Resolve DNS for a domain
    .PARAMETER Report
    Save output to a log (txt or html if extension provided)
    #>
    param(
        [switch]$Public,
        [switch]$Test,
        [switch]$Flush,
        [string]$Ping,
        [string]$Trace,
        [string]$Dns,
        [string]$Report  # auto-detects .txt / .html
    )

    # ── Setup report log ───────────────────────
    $logFile = $null
    $htmlMode = $false
    if ($Report) {
        if ([IO.Path]::GetExtension($Report) -eq "") {
            # default extension = txt
            $Report += ".txt"
        }
        $logFile = $Report
        $htmlMode = $logFile.ToLower().EndsWith(".html")
        Write-Color "📂 Logging enabled: $logFile" Yellow
        if ($htmlMode) {
            # Create HTML header
            @"
<html><head><style>
body { font-family: Consolas, monospace; background:#111; color:#eee; padding:10px; }
h2 { color:#6cf; border-bottom:1px solid #444; padding-bottom:2px; }
table { border-collapse: collapse; margin:10px 0; width:100%; }
th, td { border:1px solid #555; padding:4px 8px; text-align:left; }
th { background:#333; color:#0f0; }
tr:nth-child(even) { background:#1c1c1c; }
</style></head><body>
<h1>🌐 Network Report</h1>
<p>Generated: $(Get-Date)</p>
"@ | Out-File $logFile -Encoding utf8
        }
    }

    function Log {
        param([string]$msg, [switch]$Raw)
        if ($logFile) {
            if ($htmlMode) {
                if ($Raw) {
                    $msg | Out-File -FilePath $logFile -Append -Encoding utf8
                }
                else {
                    "<pre>$msg</pre>" | Out-File -FilePath $logFile -Append -Encoding utf8
                }
            }
            else {
                $msg | Out-File -FilePath $logFile -Append -Encoding utf8
            }
        }
    }

    function Write-Table {
        param([object[]]$data, [string]$title)
        if (-not $logFile) { return }
        if ($htmlMode) {
            Add-Content $logFile "<h2>$title</h2>"
            $data | ConvertTo-Html -Fragment | Out-File -FilePath $logFile -Append -Encoding utf8      
        }
        else {
            Add-Content $logFile "`n[$title]"
            $data | Out-String | Add-Content $logFile
        }
    }

    # ── Flush DNS ──────────────────────────────────
    if ($Flush) {
        try {
            Clear-DnsClientCache
            Write-Color "✅ DNS cache flushed successfully." Green
            Log "DNS cache flushed successfully."
        }
        catch {
            Write-Color "🚫 Failed to flush DNS: $($_.Exception.Message)" Red
            Log "Failed to flush DNS: $($_.Exception.Message)"
        }
        return
    }

    # ── Network Info ──────────────────────────────
    Write-JuiceBanner -Title "Network Diagnostics"
    Log "🌐 NETWORK INFORMATION"

    # Local adapters
    Write-Color "`n📡 Active Network Adapters" Cyan
    $adapters = Get-NetAdapter | Where-Object Status -eq "Up" |
    Select-Object Name, InterfaceDescription, LinkSpeed
    $adapters | Format-Table -AutoSize
    Write-Table $adapters "Active Network Adapters"

    # IPs
    Write-Color "🔗 IP Addresses" Cyan
    $ips = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "127.*" } |
    Select-Object InterfaceAlias, IPAddress, PrefixLength
    $ips | Format-Table -AutoSize
    Write-Table $ips "IP Addresses"

    # DNS
    Write-Color "🎯 DNS Servers" Cyan
    $dns = Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses.Count -gt 0 } |
    Select-Object InterfaceAlias, @{n = "Servers"; e = { $_.ServerAddresses -join ", " } }
    $dns | Format-Table -AutoSize
    Write-Table $dns "DNS Servers"

    # Gateway(s)
    $gateways = Get-NetRoute -DestinationPrefix "0.0.0.0/0"
    if ($gateways) {
        Write-Color "🚪 Default Gateway(s)" Cyan
        $gateways | Select-Object InterfaceAlias, NextHop | Format-Table -AutoSize
        Write-Table $gateways "Default Gateways"
    }

    # Public IP
    if ($Public) {
        Write-Color "`n🌐 Public IP" Cyan
        $publicIP = $null
        $apis = "https://ifconfig.me/ip", "https://api.ipify.org", "https://checkip.amazonaws.com"     
        foreach ($api in $apis) {
            try {
                $publicIP = (Invoke-RestMethod -Uri $api -TimeoutSec 5).Trim()
                if ($publicIP) { break }
            }
            catch {}
        }
        if ($publicIP) {
            Write-Host "Your public IP: $publicIP"
            Log "Public IP: $publicIP"
        }
        else {
            Write-Color "🚫 Failed to fetch public IP" Red
            Log "Failed to fetch public IP"
        }
    }

    # Connectivity test
    if ($Test) {
        Write-Color "`n🔌 Connectivity Test" Cyan
        $targets = @("8.8.8.8", "1.1.1.1", "google.com")
        $results = foreach ($t in $targets) {
            try {
                $ok = Test-Connection -ComputerName $t -Count 2 -Quiet -ErrorAction SilentlyContinue   
                [pscustomobject]@{Target = $t; Status = if ($ok) { "OK" }else { "Failed" } }
            }
            catch {
                [pscustomobject]@{Target = $t; Status = "Error" }
            }
        }
        $results | Format-Table -AutoSize
        Write-Table $results "Connectivity Test"
    }

    # Ping
    if ($Ping) {
        Write-Color "`n📶 Ping $Ping" Cyan
        $pingRes = Test-Connection -ComputerName $Ping -Count 4 |
        Select-Object Address, ResponseTime
        $pingRes
        Write-Table $pingRes "Ping $Ping"
    }

    # Traceroute
    if ($Trace) {
        Write-Color "`n🛰️ TraceRoute $Trace" Cyan
        $traceRes = tracert $Trace
        $traceRes | ForEach-Object { $_ }
        Log $traceRes -Raw
    }

    # DNS Lookup
    if ($Dns -match '^[a-zA-Z0-9.-]+$') {
        try {
            $dnsRes = Resolve-DnsName $Dns | Select-Object NameHost, IPAddress
            $dnsRes | Format-Table -AutoSize
            Write-Table $dnsRes "DNS Lookup for $Dns"
        }
        catch {
            Write-Color "🚫 Failed to resolve $Dns" Red
            Write-Table @() "DNS Lookup for $Dns"
            Log "Failed to resolve $Dns"
        }
    }
    else {
        Write-Color "🚫 Invalid DNS name: $Dns" Red
    }


    if ($logFile) {
        if ($htmlMode) {
            Add-Content $logFile "</body></html>"
        }
        Write-Color "`n📂 Report saved to: $logFile" Green
    }
}
