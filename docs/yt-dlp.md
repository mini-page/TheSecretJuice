\# 🎬 yt-dlp Enhancement



Interactive PowerShell wrapper for yt-dlp with menus, custom naming, and smart controls.



\## 🚀 Quick Start



```powershell

\# Interactive mode (easiest)

yt-dlp



\# With URL

yt-dlp "https://youtube.com/watch?v=..."



\# Quick download (best video)

yt-video "URL"



\# Quick audio extraction

yt-audio "URL"

```



\## 📋 Menu Options



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

| 10 | Advanced | Speed limit, dates, metadata |

| 11 | Custom Command | Enter your own yt-dlp flags |



\## 🎯 Common Usage



\### Download Best Video

```powershell

yt-dlp "URL"

\# Select option 1

```



\### Extract Audio

```powershell

yt-audio "URL"

\# Or: yt-dlp "URL" → option 2

```



\### Custom Filename

```powershell

yt-dlp "URL"

\# When prompted: Choose option 2 for custom naming

\# Enter: "my-video-name"

```



\### Download Playlist

```powershell

yt-dlp "PLAYLIST\_URL"

\# Option 4: Video playlist

\# Option 5: Audio playlist

```



\### Choose Quality

```powershell

yt-dlp "URL"

\# Option 3 → Select quality:

\# 1080p, 720p, 480p, etc.

```



\## 🔧 Advanced Features



\### Speed Limiting

```powershell

yt-dlp "URL"

\# Option 10 → 2

\# Enter: 500K (or 1M, 2M, etc.)

```



\### Download by Date

```powershell

yt-dlp "PLAYLIST\_URL"

\# Option 10 → 3

\# Enter start date: 20240101

\# Enter end date: 20241231

```



\### Custom Format Code

```powershell

yt-dlp "URL"

\# Option 6 to list formats

\# Note format code (e.g., "137+140")

\# Option 10 → 1

\# Enter: 137+140

```



\### Full Metadata

```powershell

yt-dlp "URL"

\# Option 10 → 4

\# Downloads with thumbnail + metadata embedded

```



\## 📁 Default Locations



\*\*Downloads save to:\*\*

\- Windows: `C:\\Users\\YourName\\Downloads\\youtube\\`

\- Linux/Mac: `~/Downloads/youtube/`



\*\*yt-dlp.exe auto-detected from:\*\*

\- `%USERPROFILE%\\Downloads\\yt-dlp.exe`

\- `%LOCALAPPDATA%\\Programs\\yt-dlp\\yt-dlp.exe`

\- System PATH



\## ❓ Troubleshooting



\### "yt-dlp.exe not found"

Install yt-dlp first:

```powershell

Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile "$env:USERPROFILE\\Downloads\\yt-dlp.exe"

```



\### "Download failed"

\- Check internet connection

\- Try option 9 (Fast Download)

\- Use option 10 → 2 for speed limiting



\### Custom path not working

\- Make sure path exists or will be auto-created

\- Use full path: `C:\\MyVideos\\` not `MyVideos\\`



\### Audio conversion fails

yt-dlp needs ffmpeg for conversion:

```powershell

\# Download ffmpeg and add to PATH

\# Or use option 2 which handles it automatically

```



\## 💡 Tips \& Tricks



\*\*Batch Downloads:\*\*

```powershell

\# Create a text file with URLs (one per line)

Get-Content urls.txt | ForEach-Object { yt-audio $\_ }

```



\*\*Quick Playlist Audio:\*\*

```powershell

yt-dlp "PLAYLIST\_URL"

\# Option 5 for all as MP3

```



\*\*Preview Before Download:\*\*

```powershell

yt-dlp "URL"

\# Option 6 to see all formats

\# Then exit and decide

```



\*\*Best Quality Everything:\*\*

```powershell

yt-video "URL"  # Fastest way

```



\## 🎨 Color Guide



\- 🟢 Green = Success

\- 🔴 Red = Error

\- 🔵 Cyan = Prompts/Headers

\- 🟡 Yellow = Processing

\- ⚪ Gray = Info



\## 📝 Examples



\*\*Music Video Download:\*\*

```powershell

yt-dlp "https://youtube.com/watch?v=..."

\# Option 2 (Audio Only)

```



\*\*Tutorial Playlist:\*\*

```powershell

yt-dlp "https://youtube.com/playlist?list=..."

\# Option 4 (Playlist Video)

```



\*\*Quick News Clip:\*\*

```powershell

yt-dlp "URL"

\# Option 9 (Fast Download)

```



---



\*\*Need help?\*\* Open an issue at \[github.com/mini-page/TheSecretJuice](https://github.com/mini-page/TheSecretJuice/issues)

