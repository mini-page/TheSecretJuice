# 🎬 yt-dlp-enhance

Interactive PowerShell wrapper for yt-dlp with cookie support, download archive, VLC streaming, and smart controls.

**Script file:** `yt-dlp-enhance.ps1`

## 🆕 What's New (v2.0)

- **🍪 Cookie Support** - Extract from Chrome/Firefox/Edge to bypass login/CAPTCHA
- **📚 Download Archive** - Track downloaded videos, skip duplicates
- **🌐 User-Agent Spoofing** - Fix Cloudflare 403 errors
- **🎮 VLC Streaming** - Stream directly without downloading
- **🛡️ Smart Error Detection** - Auto-suggest fixes for common issues
- **🔧 Enhanced Advanced Options** - Proxy, source IP, full metadata
- **⚡ New Quick Aliases** - `yt-playlist`, `yt-cookies`, `yt-help`

## 🚀 Quick Start

```powershell
# Interactive mode (easiest)
yt-dlp

# With URL
yt-dlp "https://youtube.com/watch?v=..."

# Quick download (best video)
yt-video "URL"

# Quick audio extraction
yt-audio "URL"

# Download playlist with archive (NEW)
yt-playlist "PLAYLIST_URL"

# Download with browser cookies (NEW)
yt-cookies "URL" chrome

# Show help (NEW)
yt-help
```

## 📋 Menu Options

| Option | Feature | What it does |
|--------|---------|--------------|
| 1 | Best Video | Downloads highest quality MP4 |
| 2 | Audio Only | Extracts and converts to MP3 |
| 3 | Choose Quality | Select from 360p to 4K |
| 4 | Playlist Video | Downloads entire playlist |
| 5 | Playlist Audio | Downloads playlist as MP3s |
| 6 | List Formats | Shows all available formats |
| 7 | With Subtitles | Embeds subtitles in video |
| 8 | With Thumbnail | Embeds thumbnail image |
| 9 | Fast Download | Quick 720p download |
| 10 | **🆕 Stream to VLC** | **Stream video to VLC player** |
| 11 | Advanced | Speed limit, dates, metadata, proxy, IP |
| 12 | Custom Command | Enter your own yt-dlp flags |

## 🍪 Cookie & Authentication Setup (NEW)

Before downloading, you can now configure cookies and user-agent to bypass blocks:

### Cookie Options:
1. **No cookies** - Default, no authentication
2. **Chrome cookies** - Extract from Chrome browser
3. **Firefox cookies** - Extract from Firefox browser
4. **Edge cookies** - Extract from Edge browser
5. **Cookie file** - Use existing cookies.txt file
6. **Export cookies** - Save browser cookies to file for reuse

### User-Agent Options:
1. **Default** - yt-dlp's user-agent
2. **Chrome** - Recommended for most sites
3. **Firefox** - Alternative browser UA
4. **Custom** - Enter your own UA string

### When to Use Cookies:
- ✅ Getting 403/429 errors
- ✅ Age-restricted videos
- ✅ Private/unlisted videos
- ✅ Rate-limited by platform
- ✅ Cloudflare blocking downloads

## 📚 Download Archive (NEW)

Track downloaded videos to avoid re-downloading:

```powershell
# Enable during interactive mode
yt-dlp "PLAYLIST_URL"
# Select archive option: 2

# Or use the quick alias
yt-playlist "PLAYLIST_URL"
```

**How it works:**
- Creates `download-archive.txt` in download folder
- Stores video IDs of successful downloads
- Skips videos already in the archive
- Perfect for regularly updated playlists/channels

## 🎯 Common Usage

### Download Best Video
```powershell
yt-dlp "URL"
# Select option 1
```

### Extract Audio
```powershell
yt-audio "URL"
# Or: yt-dlp "URL" → option 2
```

### Download with Cookies (Blocked Content)
```powershell
# Method 1: Interactive
yt-dlp "URL"
# Select cookie option (2-4)
# Select user-agent (2 for Chrome)

# Method 2: Quick alias
yt-cookies "URL" chrome
```

### Custom Filename
```powershell
yt-dlp "URL"
# When prompted: Choose option 2 for custom naming
# Enter: "my-video-name"
```

### Download Playlist
```powershell
# With archive (recommended)
yt-playlist "PLAYLIST_URL"

# Or interactive
yt-dlp "PLAYLIST_URL"
# Enable archive: option 2
# Option 4: Video playlist
# Option 5: Audio playlist
```

### Stream to VLC (NEW)
```powershell
yt-dlp "URL"
# Option 10: Stream to VLC
# Plays instantly without downloading
```

### Choose Quality
```powershell
yt-dlp "URL"
# Option 3 → Select quality:
# 1080p, 720p, 480p, etc.
```

## 🔧 Advanced Features

### Speed Limiting
```powershell
yt-dlp "URL"
# Option 11 → 2
# Enter: 500K (or 1M, 2M, etc.)
```

### Download by Date
```powershell
yt-dlp "PLAYLIST_URL"
# Option 11 → 3
# Enter start date: 20240101
# Enter end date: 20241231
```

### Custom Format Code
```powershell
yt-dlp "URL"
# Option 6 to list formats
# Note format code (e.g., "137+140")
# Option 11 → 1
# Enter: 137+140
```

### Full Metadata (Enhanced)
```powershell
yt-dlp "URL"
# Option 11 → 4
# Downloads with thumbnail + metadata + subtitles embedded
```

### Use Proxy (NEW)
```powershell
yt-dlp "URL"
# Option 11 → 5
# Enter: http://proxy.example.com:8080
```

### Specify Source IP (NEW)
```powershell
yt-dlp "URL"
# Option 11 → 6
# Enter: 192.168.1.100
# Useful for multi-IP systems
```

## 📁 Default Locations

**Downloads save to:**
- Windows: `C:\Users\YourName\Downloads\youtube\`
- Linux/Mac: `~/Downloads/youtube/`

**Download archive:**
- `C:\Users\YourName\Downloads\youtube\download-archive.txt`

**Exported cookies:**
- `C:\Users\YourName\Downloads\youtube\cookies.txt`

**yt-dlp.exe auto-detected from:**
- `%USERPROFILE%\Downloads\yt-dlp.exe`
- `%LOCALAPPDATA%\Programs\yt-dlp\yt-dlp.exe`
- System PATH

## ❓ Troubleshooting

### "yt-dlp.exe not found"
Install yt-dlp first:
```powershell
Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile "$env:USERPROFILE\Downloads\yt-dlp.exe"
```

### "HTTP Error 403: Forbidden" (NEW)
**This means the site is blocking yt-dlp. Solution:**
```powershell
yt-dlp "URL"
# Select cookie option: 2 (Chrome) or 3 (Firefox)
# Select user-agent: 2 (Chrome)
# Try download again
```

The script will auto-detect 403 errors and suggest this fix!

### "HTTP Error 429: Too Many Requests" (NEW)
**Rate limited. Solutions:**
1. Wait 5-10 minutes and retry
2. Use browser cookies (they have higher limits)
3. Enable speed limiting (Option 11 → 2)
4. Use download archive to avoid re-downloading

### "Download failed"
- Check internet connection
- Try option 9 (Fast Download)
- Use option 11 → 2 for speed limiting
- **Try with cookies if blocked**

### Custom path not working
- Make sure path exists or will be auto-created
- Use full path: `C:\MyVideos\` not `MyVideos\`

### Audio conversion fails
yt-dlp needs ffmpeg for conversion:
```powershell
# Download ffmpeg and add to PATH
# Or use option 2 which handles it automatically
```

The script will auto-detect ffmpeg issues and suggest installation!

### VLC streaming not working (NEW)
```powershell
# Install VLC Media Player
# Download from: https://www.videolan.org/
# Script will auto-detect VLC location
```

### Cookie export fails (NEW)
- Make sure you're logged into the site in your browser
- Refresh the page before exporting
- Close browser after export
- Cookies expire after 30 minutes (re-export if needed)

## 💡 Tips & Tricks

**Batch Downloads:**
```powershell
# Create a text file with URLs (one per line)
Get-Content urls.txt | ForEach-Object { yt-audio $_ }
```

**Playlist Sync (NEW):**
```powershell
# First time: downloads all
yt-playlist "PLAYLIST_URL"

# Next time: only new videos
yt-playlist "PLAYLIST_URL"
```

**Quick Playlist Audio:**
```powershell
yt-dlp "PLAYLIST_URL"
# Enable archive: 2
# Option 5 for all as MP3
```

**Preview Before Download:**
```powershell
yt-dlp "URL"
# Option 6 to see all formats
# Then exit and decide
```

**Best Quality Everything:**
```powershell
yt-video "URL"  # Fastest way
```

**Download Age-Restricted Videos (NEW):**
```powershell
# Login to YouTube in your browser first
yt-cookies "URL" chrome
```

**Stream Without Disk Space (NEW):**
```powershell
yt-dlp "URL"
# Option 10: Stream to VLC
# Watch instantly, no storage needed
```

**Bypass Cloudflare (NEW):**
```powershell
yt-dlp "URL"
# Cookie: 2 (Chrome)
# User-Agent: 2 (Chrome)
# This combo works best for Cloudflare
```

## 🎨 Color Guide

- 🟢 Green = Success
- 🔴 Red = Error
- 🔵 Cyan = Prompts/Headers
- 🟡 Yellow = Processing
- ⚪ Gray = Info

## 📝 Examples

**Music Video Download:**
```powershell
yt-dlp "https://youtube.com/watch?v=..."
# Option 2 (Audio Only)
```

**Tutorial Playlist:**
```powershell
yt-dlp "https://youtube.com/playlist?list=..."
# Archive: 2 (to skip already downloaded)
# Option 4 (Playlist Video)
```

**Quick News Clip:**
```powershell
yt-dlp "URL"
# Option 9 (Fast Download)
```

**Age-Restricted Video (NEW):**
```powershell
yt-cookies "https://youtube.com/watch?v=..." chrome
```

**Blocked Region Video (NEW):**
```powershell
yt-dlp "URL"
# Cookie: 2 (Chrome)
# User-Agent: 2 (Chrome)
# Advanced → 5 (Use proxy)
# Enter proxy URL
```

**Live Stream Recording (NEW):**
```powershell
yt-dlp "LIVE_STREAM_URL"
# Option 10: Stream to VLC (watch live)
# Or Option 1: Download (saves to file)
```

## 🚀 Performance Tips

- **Use archive** for playlists to avoid re-downloading
- **Stream to VLC** if you don't need to keep the file
- **Use fast download** (Option 9) for quick previews
- **Enable cookies** only when needed (slight overhead)
- **Use yt-video/yt-audio aliases** for quickest downloads

## 🛡️ Privacy & Security

**Cookie Safety:**
- Cookies are extracted temporarily
- Not shared with anyone
- Expire after ~30 minutes
- Can be deleted after use (`cookies.txt` file)

**Best Practices:**
- Don't share your cookies.txt file
- Re-export cookies if they expire
- Use browser-specific cookies for better security
- Delete cookie files after batch downloads

## 🔗 Quick Reference Card

```powershell
yt-dlp              # Interactive mode
yt-video <url>      # Best video
yt-audio <url>      # Extract MP3
yt-playlist <url>   # Playlist with archive
yt-cookies <url>    # With browser cookies
yt-help             # Show all commands
```

---

**Need help?** Open an issue at [github.com/mini-page/TheSecretJuice](https://github.com/mini-page/TheSecretJuice/issues)