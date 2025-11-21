# 💉 TheSecretJuice

**PowerShell steroids for your favorite command-line tools**

Transform boring CLI tools into interactive, colorful, user-friendly experiences.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ What You Get

- 🎨 **Interactive menus** - No more memorizing cryptic flags
- 🍪 **Smart features** - Cookie support, download archives, error detection
- 🎯 **Quick aliases** - One-line commands for common tasks
- 💾 **Settings memory** - Save your preferences, skip repetitive prompts
- 🌈 **Beautiful UI** - Colorful, emoji-rich interfaces

## 🚀 Quick Install

**One command to rule them all:**

```powershell
iwr https://raw.githubusercontent.com/mini-page/TheSecretJuice/main/install.ps1 | iex
```

Then reload your profile:
```powershell
. $PROFILE
```

Done! 🎉

## 📦 Available Tools

| Tool | Commands | What it does |
|------|----------|--------------|
| **[yt-dlp-enhance](docs/yt-dlp-enhance.md)** | `yt-dlp` `yt-video` `yt-audio` | Download videos/audio with menus, cookies, archives |
| **[nav-enhance](docs/nav-enhance.md)** | `zi` `zz` `bm` `ll` `la` | Smart navigation with zoxide + eza, bookmarks |
| **[robocopy-enhance](docs/robocopy-enhance.md)** | `robocopy` `robo-mirror` `robo-backup` | Smart file copying with presets, logging, scheduling |
| **fzf-enhance** | Coming soon | Fuzzy finder with presets |
| **More...** | 💡 Suggest! | What CLI tool needs juice? |

## 💡 Quick Examples

### Download YouTube Videos
```powershell
yt-dlp                    # Interactive mode
yt-video "URL"            # Quick best quality
yt-audio "URL"            # Extract MP3
yt-cookies "URL" chrome   # Use browser cookies (bypass blocks)
```

### Smart Navigation
```powershell
zi                        # Interactive fuzzy jump
zz projects               # Jump to directory
bm-add work              # Bookmark current location
bm work                  # Jump to bookmark
ll                       # Enhanced listing
```

### File Operations
```powershell
robocopy                 # Interactive file copying
robo-mirror C:\Src D:\Dst # Mirror sync
robo-backup C:\Src D:\Dst # Backup with smart skip
robo-diff C:\A C:\B      # Compare directories
robo-schedule C:\Src D:\Dst # Schedule backup
```

## 📖 Full Documentation

Each tool has detailed docs with examples and troubleshooting:

- **[yt-dlp-enhance](docs/yt-dlp-enhance.md)** - Cookies, playlists, VLC streaming, archives
**[robocopy-enhance](docs/robocopy-enhance.md)** - Presets, logging, scheduling, watch mode, exclusions

## 🎯 Why TheSecretJuice?

**Before:**
```powershell
yt-dlp --cookies-from-browser chrome --user-agent "Mozilla..." -f "bestvideo[ext=mp4]+bestaudio" --download-archive archive.txt -o "~/Downloads/%(title)s.%(ext)s" "URL"
```

**After:**
```powershell
yt-dlp "URL"  # Interactive prompts guide you
```

Or even simpler:
```powershell
yt-video "URL"  # One command, done!
```

## ⚡ Features Highlights

### yt-dlp-enhance
- 🍪 Browser cookie extraction (Chrome/Firefox/Edge)
- 📚 Download archive (skip already downloaded)
- 🎮 Stream to VLC player
- 🌐 User-agent spoofing (fix 403 errors)
- 💾 Remember settings (no repetitive prompts)
- 🛡️ Smart error detection with fix suggestions

### nav-enhance
- 🔍 Interactive fuzzy search (`zi`)
- 📚 Bookmark system (`bm-add`, `bm`)
- 🎨 Enhanced listings (`ll`, `la`, `lt`, `lz`)
- 📊 Directory stats (`lst`)
- 🚀 Quick aliases (`.`, `..`, `...`)
- 🔧 VSCode/Explorer integration (`zc`, `ze`)

### robocopy-enhance
- 🎯 Smart presets (Mirror, Sync, Backup, Fast, Verify)
- 📝 Automatic logging with timestamps
- 🚫 Pre-built exclusion filters (dev folders, system files)
- 💾 Settings memory (save preferences)
- 📊 Directory statistics and comparison
- ⏰ Scheduled backup tasks
- 👁️ Watch mode for continuous sync
- 🔐 Proper exit code handling

## 🛠️ Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

### Git Clone
```bash
git clone https://github.com/mini-page/TheSecretJuice.git
cd TheSecretJuice
```

### Windows
```powershell
$dest = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"
Copy-Item -Path ".\*" -Destination $dest -Recurse
```

### Linux/macOS
```bash
mkdir -p ~/.config/powershell/Scripts/TheSecretJuice
cp -r ./* ~/.config/powershell/Scripts/TheSecretJuice/
```

### Add to Profile
```powershell
# Edit profile
notepad $PROFILE  # Windows
nano $PROFILE     # Linux/macOS

# Add these lines:
$juicePath = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"
. "$juicePath\yt-dlp-enhance.ps1"
. "$juicePath\nav-enhance.ps1"
```

</details>

## 📋 Requirements

### PowerShell
- **Windows:** PowerShell 5.1+ (built-in)
- **Linux/macOS:** [PowerShell Core 7+](https://github.com/PowerShell/PowerShell)

### Optional CLI Tools
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - For video downloads
- **[eza](https://github.com/eza-community/eza)** - For enhanced listings
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - For smart navigation
- **[fzf](https://github.com/junegunn/fzf)** - For fuzzy finding

The installer will check for these and provide download links.

## ❓ Quick Help

```powershell
yt-help        # Show yt-dlp commands
nav-help       # Show navigation commands
yt-reset-settings  # Clear saved settings
```

## 🤝 Contributing

Got a CLI tool that needs steroids? [Open an issue](https://github.com/mini-page/TheSecretJuice/issues) or submit a PR!

**Template:** Check [CONTRIBUTING.md](CONTRIBUTING.md) for the enhancement template.

## 📜 License

MIT License - Free to use, modify, and share!

## 💬 Support

- 🐛 [Report Issues](https://github.com/mini-page/TheSecretJuice/issues)
- 💡 [Request Features](https://github.com/mini-page/TheSecretJuice/discussions)
- ⭐ Star if you find it useful!

---

**Making CLI tools feel like 2030** 💉✨

*Built with ❤️ by [mini-page](https://github.com/mini-page)*