# yt-dlp-enhance.ps1
# Enhanced yt-dlp PowerShell wrapper with cookie support, download archive, and settings memory
# Part of TheSecretJuice by mini-page

# Settings file location
$settingsFile = "$env:USERPROFILE\.ytdlp-settings.json"

# Load saved settings
function Load-Settings {
    if (Test-Path $settingsFile) {
        try {
            return Get-Content $settingsFile | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }
    return $null
}

# Save settings
function Save-Settings {
    param($settings)
    try {
        $settings | ConvertTo-Json | Out-File $settingsFile -Force
        Write-Host "   OK. Settings saved for next time!" -ForegroundColor Green
    }
    catch {
        Write-Host "   WARNING: Could not save settings" -ForegroundColor Yellow
    }
}

function yt-dlp {
    param(
        [string]$url,
        [switch]$useDefaults
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       YT-DLP Interactive     ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Load saved settings
    $savedSettings = Load-Settings
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
    
    # --- URL Input ---
    if (-not $url) {
        Write-Host "URL Input" -ForegroundColor Cyan
        $url = Read-Host "   Enter URL to download"
        if (-not $url) {
            Write-Host "   ERROR: No URL provided. Aborting.`n" -ForegroundColor Red
            return
        }
        Write-Host ""
    }

    # --- Detect yt-dlp location (IMPROVED) ---
    $ytDlpPath = $null
    
    # Check saved path first
    if ($savedSettings -and $savedSettings.ytDlpPath -and (Test-Path $savedSettings.ytDlpPath)) {
        $ytDlpPath = $savedSettings.ytDlpPath
        Write-Host "OK. Found yt-dlp: " -ForegroundColor Green -NoNewline
        Write-Host "$ytDlpPath (from saved settings)`n" -ForegroundColor Gray
    }
    else {
        # Search in common locations
        $possiblePaths = @(
            "$env:USERPROFILE\Downloads\yt-dlp.exe",
            "$env:LOCALAPPDATA\Programs\yt-dlp\yt-dlp.exe",
            "$env:APPDATA\yt-dlp\yt-dlp.exe",
            "$env:ProgramFiles\yt-dlp\yt-dlp.exe",
            "${env:ProgramFiles(x86)}\yt-dlp\yt-dlp.exe"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $ytDlpPath = $path
                break
            }
        }
        
        # Check PATH
        if (-not $ytDlpPath) {
            $ytDlpPath = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
        }
        
        # If still not found, ask user
        if (-not $ytDlpPath) {
            Write-Host "WARNING: yt-dlp.exe not found in common locations" -ForegroundColor Yellow
            Write-Host "   1. Enter custom path" -ForegroundColor White
            Write-Host "   2. Download yt-dlp now" -ForegroundColor White
            Write-Host "   3. Abort" -ForegroundColor White
            $ytChoice = Read-Host "   Choice (1-3)"
            
            switch ($ytChoice) {
                "1" {
                    $customPath = Read-Host "   Enter full path to yt-dlp.exe"
                    if ($customPath -and (Test-Path $customPath)) {
                        $ytDlpPath = $customPath
                        Write-Host "   OK. Found: $ytDlpPath" -ForegroundColor Green
                    }
                    else {
                        Write-Host "   ERROR: Invalid path. Aborting." -ForegroundColor Red
                        return
                    }
                }
                "2" {
                    $downloadPath = "$env:USERPROFILE\Downloads\yt-dlp.exe"
                    Write-Host "   Downloading yt-dlp to: $downloadPath" -ForegroundColor Cyan
                    try {
                        Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile $downloadPath
                        $ytDlpPath = $downloadPath
                        Write-Host "   OK. Downloaded successfully!" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "   ERROR: Download failed: $_" -ForegroundColor Red
                        return
                    }
                }
                default {
                    Write-Host "   ERROR: Aborting." -ForegroundColor Red
                    return
                }
            }
        }
        else {
            Write-Host "OK. Found yt-dlp: " -ForegroundColor Green -NoNewline
            Write-Host "$ytDlpPath`n" -ForegroundColor Gray
        }
    }
    
    # Initialize settings object
    $currentSettings = @{
        ytDlpPath = $ytDlpPath
        downloadPath = ""
        cookieChoice = "1"
        userAgentChoice = "1"
        archiveChoice = "1"
    }
    
    # --- Download Path Setup ---
    $defaultPath = "$env:USERPROFILE\Downloads\youtube"
    
    if ($useDefaults -or ($savedSettings -and $settingChoice -eq "1")) {
        $downloadPath = if ($savedSettings.downloadPath) { $savedSettings.downloadPath } else { $defaultPath }
        Write-Host "Download Location: " -ForegroundColor Cyan -NoNewline
        Write-Host "$downloadPath" -ForegroundColor Yellow
    }
    else {
        Write-Host "Download Location" -ForegroundColor Cyan
        Write-Host "   Default: " -NoNewline -ForegroundColor Gray
        Write-Host "$defaultPath" -ForegroundColor Yellow
        if ($savedSettings.downloadPath) {
            Write-Host "   Saved: " -NoNewline -ForegroundColor Gray
            Write-Host "$($savedSettings.downloadPath)" -ForegroundColor Cyan
        }
        $pathChoice = Read-Host "   Custom path (or Enter for default)"
        
        $downloadPath = if ($pathChoice) { $pathChoice } else { $defaultPath }
    }
    
    $currentSettings.downloadPath = $downloadPath
    
    if (-not (Test-Path -Path $downloadPath)) {
        try {
            New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
            Write-Host "   OK. Created: $downloadPath`n" -ForegroundColor Green
        }
        catch {
            Write-Host "   ERROR: Failed to create directory: $_`n" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "   OK. Using: $downloadPath`n" -ForegroundColor Green
    }
    
    # --- Cookie & Authentication Setup ---
    $cookieArgs = ""
    
    if ($useDefaults) {
        Write-Host "Cookies: " -ForegroundColor Cyan -NoNewline
        Write-Host "None (default)`n" -ForegroundColor Gray
    }
    elseif ($savedSettings -and $settingChoice -eq "1") {
        $cookieChoice = $savedSettings.cookieChoice
        $currentSettings.cookieChoice = $cookieChoice
        
        switch ($cookieChoice) {
            "2" { $cookieArgs = "--cookies-from-browser chrome"; Write-Host "Cookies: Chrome (saved)`n" -ForegroundColor Cyan }
            "3" { $cookieArgs = "--cookies-from-browser firefox"; Write-Host "Cookies: Firefox (saved)`n" -ForegroundColor Cyan }
            "4" { $cookieArgs = "--cookies-from-browser edge"; Write-Host "Cookies: Edge (saved)`n" -ForegroundColor Cyan }
            default { Write-Host "Cookies: None`n" -ForegroundColor Cyan }
        }
    }
    else {
        Write-Host "Cookie & Authentication (for blocked/private content)" -ForegroundColor Cyan
        Write-Host "   1. No cookies (default)" -ForegroundColor White
        Write-Host "   2. Use browser cookies (Chrome)" -ForegroundColor White
        Write-Host "   3. Use browser cookies (Firefox)" -ForegroundColor White
        Write-Host "   4. Use browser cookies (Edge)" -ForegroundColor White
        Write-Host "   5. Use cookie file" -ForegroundColor White
        Write-Host "   6. Export cookies from browser to file" -ForegroundColor White
        $cookieChoice = Read-Host "   Choice (1-6, default: 1)"
        
        $currentSettings.cookieChoice = $cookieChoice
        
        switch ($cookieChoice) {
            "2" { 
                $cookieArgs = "--cookies-from-browser chrome"
                Write-Host "   OK. Using Chrome cookies" -ForegroundColor Green
            }
            "3" { 
                $cookieArgs = "--cookies-from-browser firefox"
                Write-Host "   OK. Using Firefox cookies" -ForegroundColor Green
            }
            "4" { 
                $cookieArgs = "--cookies-from-browser edge"
                Write-Host "   OK. Using Edge cookies" -ForegroundColor Green
            }
            "5" {
                $cookieFile = Read-Host "   Enter path to cookie file"
                if ($cookieFile -and (Test-Path $cookieFile)) {
                    $cookieArgs = "--cookies ""$cookieFile"""
                    Write-Host "   OK. Using cookie file" -ForegroundColor Green
                } else {
                    Write-Host "   WARNING: Cookie file not found, continuing without cookies" -ForegroundColor Yellow
                }
            }
            "6" {
                Write-Host "   Select browser to export from:" -ForegroundColor Cyan
                Write-Host "   1. Chrome" -ForegroundColor White
                Write-Host "   2. Firefox" -ForegroundColor White
                Write-Host "   3. Edge" -ForegroundColor White
                $exportBrowser = Read-Host "   Choice (1-3)"
                
                $browserName = switch ($exportBrowser) {
                    "1" { "chrome" }
                    "2" { "firefox" }
                    "3" { "edge" }
                    default { "chrome" }
                }
                
                $cookieExportPath = "$downloadPath\cookies.txt"
                Write-Host "   Exporting cookies to: $cookieExportPath" -ForegroundColor Yellow
                
                try {
                    & $ytDlpPath --cookies-from-browser $browserName --cookies $cookieExportPath $url --skip-download
                    if (Test-Path $cookieExportPath) {
                        Write-Host "   OK. Cookies exported successfully!" -ForegroundColor Green
                        $cookieArgs = "--cookies ""$cookieExportPath"""
                    }
                }
                catch {
                    Write-Host "   ERROR: Cookie export failed: $_" -ForegroundColor Red
                }
            }
        }
        Write-Host ""
    }
    
    # --- User-Agent Setup ---
    $userAgentArgs = ""
    
    if ($useDefaults) {
        Write-Host "User-Agent: " -ForegroundColor Cyan -NoNewline
        Write-Host "Default`n" -ForegroundColor Gray
    }
    elseif ($savedSettings -and $settingChoice -eq "1") {
        $uaChoice = $savedSettings.userAgentChoice
        $currentSettings.userAgentChoice = $uaChoice
        
        switch ($uaChoice) {
            "2" { 
                $userAgentArgs = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"'
                Write-Host "User-Agent: Chrome (saved)`n" -ForegroundColor Cyan
            }
            "3" { 
                $userAgentArgs = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"'
                Write-Host "User-Agent: Firefox (saved)`n" -ForegroundColor Cyan
            }
            default { Write-Host "User-Agent: Default`n" -ForegroundColor Cyan }
        }
    }
    else {
        Write-Host "User-Agent (helps with blocked content)" -ForegroundColor Cyan
        Write-Host "   1. Default (yt-dlp)" -ForegroundColor White
        Write-Host "   2. Chrome (recommended)" -ForegroundColor White
        Write-Host "   3. Firefox" -ForegroundColor White
        Write-Host "   4. Custom" -ForegroundColor White
        $uaChoice = Read-Host "   Choice (1-4, default: 1)"
        
        $currentSettings.userAgentChoice = $uaChoice
        
        switch ($uaChoice) {
            "2" {
                $userAgentArgs = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"'
                Write-Host "   OK. Using Chrome User-Agent" -ForegroundColor Green
            }
            "3" {
                $userAgentArgs = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"'
                Write-Host "   OK. Using Firefox User-Agent" -ForegroundColor Green
            }
            "4" {
                $customUA = Read-Host "   Enter custom User-Agent"
                if ($customUA) {
                    $userAgentArgs = "--user-agent ""$customUA"""
                    Write-Host "   OK. Using custom User-Agent" -ForegroundColor Green
                }
            }
        }
        Write-Host ""
    }
    
    # --- Download Archive Setup ---
    $archiveArgs = ""
    
    if ($useDefaults) {
        Write-Host "Archive: " -ForegroundColor Cyan -NoNewline
        Write-Host "Disabled`n" -ForegroundColor Gray
    }
    elseif ($savedSettings -and $settingChoice -eq "1") {
        $archiveChoice = $savedSettings.archiveChoice
        $currentSettings.archiveChoice = $archiveChoice
        
        if ($archiveChoice -eq "2") {
            $archiveFile = "$downloadPath\download-archive.txt"
            $archiveArgs = "--download-archive ""$archiveFile"""
            Write-Host "Archive: Enabled (saved)`n" -ForegroundColor Cyan
        }
        else {
            Write-Host "Archive: Disabled`n" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "Download Archive (track downloaded videos)" -ForegroundColor Cyan
        Write-Host "   1. No archive (download everything)" -ForegroundColor White
        Write-Host "   2. Use archive (skip already downloaded)" -ForegroundColor White
        $archiveChoice = Read-Host "   Choice (1-2, default: 1)"
        
        $currentSettings.archiveChoice = $archiveChoice
        
        if ($archiveChoice -eq "2") {
            $archiveFile = "$downloadPath\download-archive.txt"
            $archiveArgs = "--download-archive ""$archiveFile"""
            Write-Host "   OK. Using archive: $archiveFile" -ForegroundColor Green
            Write-Host "   INFO: Videos in this file will be skipped" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    # Save settings for next time (only if not using defaults this time)
    if (-not $useDefaults -and $settingChoice -ne "1") {
        Write-Host "Save these settings for next time? (Y/n): " -ForegroundColor Cyan -NoNewline
        $saveChoice = Read-Host
        if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
            Save-Settings $currentSettings
        }
        Write-Host ""
    }
    
    # --- File Naming ---
    Write-Host "File Naming" -ForegroundColor Cyan
    Write-Host "   1. Auto (use video title)" -ForegroundColor White
    Write-Host "   2. Custom name" -ForegroundColor White
    $nameChoice = Read-Host "   Choice (1-2, default: 1)"
    
    $outputTemplate = "%(title)s.%(ext)s"
    if ($nameChoice -eq "2") {
        $customName = Read-Host "   Enter filename (without extension)"
        if ($customName) {
            $outputTemplate = "$customName.%(ext)s"
        }
    }
    Write-Host ""
    
    # --- Main Menu ---
    Write-Host "DOWNLOAD OPTIONS" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $options = @(
        "1.  Best Video (MP4)",
        "2.  Audio Only (MP3)",
        "3.  Choose Video Quality",
        "4.  Playlist (Best Quality)",
        "5.  Playlist (Audio Only)",
        "6.  List Available Formats",
        "7.  Download with Subtitles",
        "8.  Download with Thumbnail",
        "9.  Fast Download (lower quality)",
        "10. Stream to VLC Player",
        "11. Advanced Options",
        "12. Custom Command"
    )
    
    $options | ForEach-Object { Write-Host "   $_" }
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    $choice = Read-Host "Enter choice (1-12)"
    
    # --- Base Command ---
    $baseCommand = "& `"$ytDlpPath`" -o ""$downloadPath\$outputTemplate"" $cookieArgs $userAgentArgs $archiveArgs"
    
    # --- Command Construction ---
    switch ($choice) {
        "1" {
            Write-Host "`nDownloading best video..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --merge-output-format mp4 $url"
        }
        "2" {
            Write-Host "`nExtracting audio..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestaudio/best' -x --audio-format mp3 --audio-quality 0 $url"
        }
        "3" {
            Write-Host "`nVideo Quality:" -ForegroundColor Cyan
            $qualityOptions = @(
                "1. Best (Auto)",
                "2. 4K (2160p)",
                "3. 1440p",
                "4. 1080p",
                "5. 720p",
                "6. 480p",
                "7. 360p"
            )
            $qualityOptions | ForEach-Object { Write-Host "   $_" }
            $qualityChoice = Read-Host "`n   Select quality (1-7)"
            
            $qualityFormat = switch ($qualityChoice) {
                "1" { "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" }
                "2" { "bestvideo[height<=2160][ext=mp4]+bestaudio[ext=m4a]/best[height<=2160]" }
                "3" { "bestvideo[height<=1440][ext=mp4]+bestaudio[ext=m4a]/best[height<=1440]" }
                "4" { "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080]" }
                "5" { "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720]" }
                "6" { "bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480]" }
                "7" { "bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]/best[height<=360]" }
                default { "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" }
            }
            $finalCommand = "$baseCommand -f ""$qualityFormat"" --merge-output-format mp4 $url"
        }
        "4" {
            Write-Host "`nDownloading playlist (video)..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --merge-output-format mp4 --yes-playlist $url"
        }
        "5" {
            Write-Host "`nDownloading playlist (audio)..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestaudio/best' -x --audio-format mp3 --yes-playlist $url"
        }
        "6" {
            Write-Host "`nListing available formats...`n" -ForegroundColor Yellow
            & $ytDlpPath -F $url
            Write-Host "`nOK. Format list complete`n" -ForegroundColor Green
            return
        }
        "7" {
            Write-Host "`nDownloading with subtitles..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --write-auto-sub --sub-lang en --merge-output-format mp4 $url"
        }
        "8" {
            Write-Host "`nDownloading with thumbnail..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --write-thumbnail --merge-output-format mp4 $url"
        }
        "9" {
            Write-Host "`nFast download mode..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'best[height<=720]/best' $url"
        }
        "10" {
            Write-Host "`nStream to VLC Player..." -ForegroundColor Yellow
            
            # Check if VLC is installed
            $vlcPaths = @(
                "$env:ProgramFiles\VideoLAN\VLC\vlc.exe",
                "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc.exe",
                "vlc.exe"
            )
            
            $vlcPath = $null
            foreach ($path in $vlcPaths) {
                if (Get-Command $path -ErrorAction SilentlyContinue) {
                    $vlcPath = $path
                    break
                }
            }
            
            if (-not $vlcPath) {
                $vlcPath = (Get-Command vlc -ErrorAction SilentlyContinue).Source
            }
            
            if ($vlcPath) {
                Write-Host "   OK. Found VLC: $vlcPath" -ForegroundColor Green
                Write-Host "   Starting stream..." -ForegroundColor Cyan
                $streamCommand = "$baseCommand -o - --downloader ffmpeg -f 'bv*+ba/b' $url"
                Write-Host "   Executing: $streamCommand | vlc -" -ForegroundColor Gray
                Invoke-Expression "$streamCommand | & ""$vlcPath"" -"
                return
            } else {
                Write-Host "   ERROR: VLC not found! Please install VLC Media Player." -ForegroundColor Red
                Write-Host "   Download from: https://www.videolan.org/" -ForegroundColor Yellow
                return
            }
        }
        "11" {
            Write-Host "`nAdvanced Options:" -ForegroundColor Cyan
            Write-Host "   1. Download specific format code" -ForegroundColor White
            Write-Host "   2. Limit download speed" -ForegroundColor White
            Write-Host "   3. Download date range (playlist)" -ForegroundColor White
            Write-Host "   4. Download with full metadata" -ForegroundColor White
            Write-Host "   5. Use proxy" -ForegroundColor White
            Write-Host "   6. Specify source IP address" -ForegroundColor White
            $advChoice = Read-Host "`n   Select option (1-6)"
            
            switch ($advChoice) {
                "1" {
                    $formatCode = Read-Host "   Enter format code (use option 6 to list)"
                    $finalCommand = "$baseCommand -f $formatCode $url"
                }
                "2" {
                    $speedLimit = Read-Host "   Enter speed limit (e.g., 500K, 1M)"
                    $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' -r $speedLimit $url"
                }
                "3" {
                    $dateAfter = Read-Host "   Download after date (YYYYMMDD)"
                    $dateBefore = Read-Host "   Download before date (YYYYMMDD)"
                    $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --dateafter $dateAfter --datebefore $dateBefore $url"
                }
                "4" {
                    $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --add-metadata --embed-thumbnail --embed-subs --merge-output-format mp4 $url"
                }
                "5" {
                    $proxyUrl = Read-Host "   Enter proxy URL (e.g., http://proxy:port)"
                    $finalCommand = "$baseCommand --proxy ""$proxyUrl"" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' $url"
                }
                "6" {
                    $sourceIP = Read-Host "   Enter source IP address"
                    $finalCommand = "$baseCommand --source-address ""$sourceIP"" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' $url"
                }
                default {
                    Write-Host "   ERROR: Invalid choice. Aborting." -ForegroundColor Red
                    return
                }
            }
        }
        "12" {
            Write-Host "`nCustom Command Mode" -ForegroundColor Cyan
            Write-Host "   Example: -f best -x --audio-format mp3`n" -ForegroundColor Gray
            $customCommand = Read-Host "   Enter yt-dlp arguments"
            $finalCommand = "$baseCommand $customCommand $url"
        }
        default {
            Write-Host "`nERROR: Invalid choice. Aborting.`n" -ForegroundColor Red
            return
        }
    }
    
    # --- Execute Command ---
    Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "Executing: " -ForegroundColor Green -NoNewline
    Write-Host "$finalCommand" -ForegroundColor Gray
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    try {
        $startTime = Get-Date
        Invoke-Expression $finalCommand
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "OK. Download complete! " -ForegroundColor Green -NoNewline
        Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
        Write-Host "Saved to: $downloadPath" -ForegroundColor Cyan
        Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "ERROR: Download failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Yellow
        
        # Smart error detection and suggestions
        $errorMsg = $_.Exception.Message
        
        if ($errorMsg -match "403|Forbidden") {
            Write-Host "`nTIP: Got 403 error? Try using browser cookies!" -ForegroundColor Cyan
            Write-Host "   Run the command again and select cookie option (2-4)" -ForegroundColor Gray
            Write-Host "   Also try using a User-Agent (option 2 or 3)" -ForegroundColor Gray
        }
        elseif ($errorMsg -match "429|Too Many Requests") {
            Write-Host "`nTIP: Rate limited! Try:" -ForegroundColor Cyan
            Write-Host "   - Wait a few minutes and try again" -ForegroundColor Gray
            Write-Host "   - Use speed limiting (Advanced > Option 2)" -ForegroundColor Gray
            Write-Host "   - Use browser cookies to bypass" -ForegroundColor Gray
        }
        elseif ($errorMsg -match "codec|ffmpeg") {
            Write-Host "`nTIP: FFmpeg issue detected!" -ForegroundColor Cyan
            Write-Host "   Make sure ffmpeg is installed and in PATH" -ForegroundColor Gray
            Write-Host "   Download from: https://ffmpeg.org/" -ForegroundColor Gray
        }
        
        Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    }
}

# --- Quick aliases ---
function yt-video { 
    param([string]$url)
    if (-not $url) {
        Write-Host "Usage: yt-video [url]" -ForegroundColor Yellow
        return
    }
    $path = "$env:USERPROFILE\Downloads\youtube"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    
    # Find yt-dlp
    $ytdlp = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
    if (-not $ytdlp) {
        $ytdlp = "$env:USERPROFILE\Downloads\yt-dlp.exe"
    }
    
    & $ytdlp -o "$path\%(title)s.%(ext)s" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --merge-output-format mp4 $url
}

function yt-audio { 
    param([string]$url)
    if (-not $url) {
        Write-Host "Usage: yt-audio [url]" -ForegroundColor Yellow
        return
    }
    $path = "$env:USERPROFILE\Downloads\youtube"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    
    # Find yt-dlp
    $ytdlp = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
    if (-not $ytdlp) {
        $ytdlp = "$env:USERPROFILE\Downloads\yt-dlp.exe"
    }
    
    & $ytdlp -o "$path\%(title)s.%(ext)s" -f 'bestaudio/best' -x --audio-format mp3 --audio-quality 0 $url 
}

function yt-playlist {
    param([string]$url)
    if (-not $url) {
        Write-Host "Usage: yt-playlist [url]" -ForegroundColor Yellow
        return
    }
    $path = "$env:USERPROFILE\Downloads\youtube"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    $archive = "$path\download-archive.txt"
    
    # Find yt-dlp
    $ytdlp = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
    if (-not $ytdlp) {
        $ytdlp = "$env:USERPROFILE\Downloads\yt-dlp.exe"
    }
    
    & $ytdlp -o "$path\%(title)s.%(ext)s" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --download-archive $archive --yes-playlist $url
}

function yt-cookies {
    param(
        [string]$url,
        [string]$browser = "chrome"
    )
    if (-not $url) {
        Write-Host "Usage: yt-cookies [url] [browser]" -ForegroundColor Yellow
        Write-Host "Browser: chrome, firefox, edge (default: chrome)" -ForegroundColor Gray
        return
    }
    $path = "$env:USERPROFILE\Downloads\youtube"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    
    # Find yt-dlp
    $ytdlp = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
    if (-not $ytdlp) {
        $ytdlp = "$env:USERPROFILE\Downloads\yt-dlp.exe"
    }
    
    & $ytdlp -o "$path\%(title)s.%(ext)s" --cookies-from-browser $browser -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' $url
}

function yt-defaults {
    param([string]$url)
    if (-not $url) {
        Write-Host "Usage: yt-defaults [url]" -ForegroundColor Yellow
        Write-Host "Quick download with default settings (no prompts)" -ForegroundColor Gray
        return
    }
    yt-dlp $url -useDefaults
}

function yt-reset-settings {
    $settingsFile = "$env:USERPROFILE\.ytdlp-settings.json"
    if (Test-Path $settingsFile) {
        Remove-Item $settingsFile -Force
        Write-Host "OK. Settings reset! Next run will prompt for new settings." -ForegroundColor Green
    }
    else {
        Write-Host "WARNING: No saved settings found." -ForegroundColor Yellow
    }
}

# Help function
function yt-help {
    Write-Host "`nYT-DLP QUICK REFERENCE" -ForegroundColor Magenta
    Write-Host "═════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "  yt-dlp [url]          " -NoNewline -ForegroundColor Green
    Write-Host "Interactive mode" -ForegroundColor Gray
    Write-Host "  yt-defaults [url]     " -NoNewline -ForegroundColor Green
    Write-Host "Quick download (no prompts)" -ForegroundColor Gray
    Write-Host "  yt-video [url]        " -NoNewline -ForegroundColor Green
    Write-Host "Download best video" -ForegroundColor Gray
    Write-Host "  yt-audio [url]        " -NoNewline -ForegroundColor Green
    Write-Host "Extract audio as MP3" -ForegroundColor Gray
    Write-Host "  yt-playlist [url]     " -NoNewline -ForegroundColor Green
    Write-Host "Download playlist (with archive)" -ForegroundColor Gray
    Write-Host "  yt-cookies [url]      " -NoNewline -ForegroundColor Green
    Write-Host "Download with browser cookies" -ForegroundColor Gray
    Write-Host "  yt-reset-settings     " -NoNewline -ForegroundColor Green
    Write-Host "Clear saved settings" -ForegroundColor Gray
    Write-Host "═════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "`nINFO: Settings are saved automatically!" -ForegroundColor Cyan
    Write-Host "   Next time: Choose 'Use saved settings' to skip prompts`n" -ForegroundColor Gray
}

Write-Host "OK. yt-dlp-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'yt-help' for commands" -ForegroundColor Cyan
