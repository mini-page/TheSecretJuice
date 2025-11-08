function yt-dlp {
    param(
        [string]$url
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       YT-DLP intractive      ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
     # --- URL Input ---
    if (-not $url) {
        Write-Host "🔗 URL Input" -ForegroundColor Cyan
        $url = Read-Host "   Enter URL to download"
        if (-not $url) {
            Write-Host "   ❌ No URL provided. Aborting.`n" -ForegroundColor Red
            return
        }
        Write-Host ""
    }

    # --- Detect yt-dlp.exe location ---
    $ytDlpPath = $null
    $possiblePaths = @(
        "$env:USERPROFILE\Downloads\yt-dlp.exe",
        "$env:LOCALAPPDATA\Programs\yt-dlp\yt-dlp.exe",
        "yt-dlp.exe"  # In PATH
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $ytDlpPath = $path
            break
        }
    }
    
    if (-not $ytDlpPath) {
        $ytDlpPath = (Get-Command yt-dlp -ErrorAction SilentlyContinue).Source
        if (-not $ytDlpPath) {
            Write-Host "❌ yt-dlp.exe not found! Please install it first." -ForegroundColor Red
            return
        }
    }
    
    Write-Host "✓ Found yt-dlp: " -ForegroundColor Green -NoNewline
    Write-Host "$ytDlpPath`n" -ForegroundColor Gray
    
    # --- Download Path Setup ---
    $defaultPath = "$env:USERPROFILE\Downloads\youtube"
    $downloadPath = $defaultPath
    
    Write-Host "📁 Download Location" -ForegroundColor Cyan
    Write-Host "   Default: " -NoNewline -ForegroundColor Gray
    Write-Host "$defaultPath" -ForegroundColor Yellow
    $pathChoice = Read-Host "   Custom path (or Enter for default)"
    
    if ($pathChoice) {
        $downloadPath = $pathChoice
    }
    
    # Create directory if it doesn't exist
    if (-not (Test-Path -Path $downloadPath)) {
        try {
            New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
            Write-Host "   ✓ Created: $downloadPath`n" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Failed to create directory: $_`n" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "   ✓ Using: $downloadPath`n" -ForegroundColor Green
    }
    
    # --- File Naming ---
    Write-Host "📝 File Naming" -ForegroundColor Cyan
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
    Write-Host "🎬 DOWNLOAD OPTIONS" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $options = @(
        "1.  📹 Best Video (MP4)",
        "2.  🎵 Audio Only (MP3)",
        "3.  🎯 Choose Video Quality",
        "4.  📋 Playlist (Best Quality)",
        "5.  📋 Playlist (Audio Only)",
        "6.  📺 List Available Formats",
        "7.  💬 Download with Subtitles",
        "8.  🖼️  Download with Thumbnail",
        "9.  ⚡ Fast Download (lower quality)",
        "10. 🔧 Advanced Options",
        "11. 💻 Custom Command"
    )
    
    $options | ForEach-Object { Write-Host "   $_" }
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    $choice = Read-Host "Enter choice (1-11)"
    
    # --- Base Command ---
    $baseCommand = "$ytDlpPath -o ""$downloadPath\$outputTemplate"""
    
    # --- Command Construction ---
    switch ($choice) {
        "1" {
            Write-Host "`n⚙️  Downloading best video..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --merge-output-format mp4 $url"
        }
        "2" {
            Write-Host "`n⚙️  Extracting audio..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestaudio/best' -x --audio-format mp3 --audio-quality 0 $url"
        }
        "3" {
            Write-Host "`n📐 Video Quality:" -ForegroundColor Cyan
            $qualityOptions = @(
                "1. 🔥 Best (Auto)",
                "2. 🎬 4K (2160p)",
                "3. 📺 1440p",
                "4. 💎 1080p",
                "5. ⚡ 720p",
                "6. 📱 480p",
                "7. 🌐 360p"
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
            $finalCommand = "$baseCommand -f `"$qualityFormat`" --merge-output-format mp4 $url"
        }
        "4" {
            Write-Host "`n⚙️  Downloading playlist (video)..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --merge-output-format mp4 --yes-playlist $url"
        }
        "5" {
            Write-Host "`n⚙️  Downloading playlist (audio)..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestaudio/best' -x --audio-format mp3 --yes-playlist $url"
        }
        "6" {
            Write-Host "`n📊 Listing available formats...`n" -ForegroundColor Yellow
            & $ytDlpPath -F $url
            Write-Host "`n✓ Format list complete`n" -ForegroundColor Green
            return
        }
        "7" {
            Write-Host "`n⚙️  Downloading with subtitles..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --write-auto-sub --sub-lang en --merge-output-format mp4 $url"
        }
        "8" {
            Write-Host "`n⚙️  Downloading with thumbnail..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --write-thumbnail --merge-output-format mp4 $url"
        }
        "9" {
            Write-Host "`n⚙️  Fast download mode..." -ForegroundColor Yellow
            $finalCommand = "$baseCommand -f 'best[height<=720]/best' $url"
        }
        "10" {
            Write-Host "`n🔧 Advanced Options:" -ForegroundColor Cyan
            Write-Host "   1. Download specific format code" -ForegroundColor White
            Write-Host "   2. Limit download speed" -ForegroundColor White
            Write-Host "   3. Download date range (playlist)" -ForegroundColor White
            Write-Host "   4. Download with metadata" -ForegroundColor White
            $advChoice = Read-Host "`n   Select option (1-4)"
            
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
                    $finalCommand = "$baseCommand -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best' --add-metadata --embed-thumbnail --merge-output-format mp4 $url"
                }
                default {
                    Write-Host "   ❌ Invalid choice. Aborting." -ForegroundColor Red
                    return
                }
            }
        }
        "11" {
            Write-Host "`n💻 Custom Command Mode" -ForegroundColor Cyan
            Write-Host "   Example: -f best -x --audio-format mp3`n" -ForegroundColor Gray
            $customCommand = Read-Host "   Enter yt-dlp arguments"
            $finalCommand = "$ytDlpPath -o ""$downloadPath\$outputTemplate"" $customCommand $url"
        }
        default {
            Write-Host "`n❌ Invalid choice. Aborting.`n" -ForegroundColor Red
            return
        }
    }
    
    # --- Execute Command ---
    Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "🚀 Executing: " -ForegroundColor Green -NoNewline
    Write-Host "$finalCommand" -ForegroundColor Gray
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    try {
        $startTime = Get-Date
        Invoke-Expression $finalCommand
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "✅ Download complete! " -ForegroundColor Green -NoNewline
        Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
        Write-Host "📁 Saved to: $downloadPath" -ForegroundColor Cyan
        Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "❌ Download failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Yellow
        Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    }
}

# --- BONUS: Quick aliases for common tasks ---
function yt-video { param([string]$url) & yt-dlp $url }
function yt-audio { param([string]$url) 
    $path = "$env:USERPROFILE\Downloads\youtube"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    & "yt-dlp.exe" -o "$path\%(title)s.%(ext)s" -f 'bestaudio/best' -x --audio-format mp3 $url 
}

#Write-Host "✓ yt-dlp function loaded! Quick aliases: " -ForegroundColor Green -NoNewline
#Write-Host "yt-video, yt-audio" -ForegroundColor Cyan