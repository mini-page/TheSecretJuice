# 💉 TheSecretJuice

**PowerShell steroids for your favorite command-line tools**

Transform boring CLI tools into interactive, colorful, user-friendly experiences. Because command-line tools deserve better UX.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 What is This?

Command-line tools are powerful but often cryptic. **TheSecretJuice** wraps them with:
- 🎨 **Interactive menus** - No more memorizing flags
- 🌈 **Colorful interfaces** - Visual clarity with emojis
- 🛡️ **Smart error handling** - Auto-create directories, validate inputs
- 🚀 **Quick aliases** - Shortcuts for common tasks
- 📝 **Custom workflows** - Build on top of existing tools

## 📦 Available Enhancements

| Tool | Script | Status | Description |
|------|--------|--------|-------------|
| **yt-dlp** | `yt-dlp.ps1` | ✅ Ready | Interactive video/audio downloader with quality selection, playlists, subtitles |
| **fzf** | `fzf-enhance.ps1` | 🚧 Coming Soon | Fuzzy finder with preset workflows |
| **PSReadLine** | `readline-enhance.ps1` | 🚧 Coming Soon | Enhanced command-line editing experience |
| **zoxide** | `zoxide-enhance.ps1` | 🚧 Coming Soon | Smart directory jumping with interactive selection |
| More... | - | 💡 Planned | Suggest your favorite CLI tool! |

## 🚀 Quick Start

### Prerequisites
- **PowerShell 5.1+** (Windows) or **PowerShell Core 7+** (Linux/macOS)
- The original CLI tools you want to enhance (e.g., yt-dlp, fzf, etc.)

### Installation

#### Option 1: One-Line Install (Recommended)
```powershell
# Download all scripts
$scriptsPath = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"
New-Item -ItemType Directory -Path $scriptsPath -Force
Invoke-WebRequest -Uri "https://github.com/mini-page/TheSecretJuice/archive/refs/heads/main.zip" -OutFile "$env:TEMP\TheSecretJuice.zip"
Expand-Archive -Path "$env:TEMP\TheSecretJuice.zip" -DestinationPath "$scriptsPath" -Force
```

#### Option 2: Git Clone
```bash
# Clone the repository
git clone https://github.com/mini-page/TheSecretJuice.git

# For Windows
$scriptsPath = "$env:USERPROFILE\Documents\PowerShell\Scripts"
Copy-Item -Path ".\TheSecretJuice\*" -Destination "$scriptsPath\TheSecretJuice\" -Recurse

# For Linux/macOS
mkdir -p ~/.config/powershell/Scripts
cp -r ./TheSecretJuice/* ~/.config/powershell/Scripts/TheSecretJuice/
```

### Add to PowerShell Profile

```powershell
# Open your profile
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }
notepad $PROFILE  # Windows
# or: nano $PROFILE  # Linux/macOS
```

Add these lines to load all enhancements:

```powershell
# TheSecretJuice - CLI Tool Enhancements
$juicePath = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice"  # Windows
# $juicePath = "$HOME/.config/powershell/Scripts/TheSecretJuice"  # Linux/macOS

# Load individual enhancements
. "$juicePath\yt-dlp.ps1"
# . "$juicePath\fzf-enhance.ps1"      # Uncomment when available
# . "$juicePath\readline-enhance.ps1"
# . "$juicePath\zoxide-enhance.ps1"
```

Reload your profile:
```powershell
. $PROFILE
```

## 📖 Usage Examples

### yt-dlp Enhancement
```powershell
# Interactive mode - just run it
yt-dlp

# Or with URL
yt-dlp "https://youtube.com/watch?v=..."

# Quick aliases
yt-video "URL"  # Best quality video
yt-audio "URL"  # Extract audio as MP3
```

### More tools coming soon...

## 🛠️ Repository Structure

```
TheSecretJuice/
├── README.md                 # This file
├── LICENSE                   # MIT License
├── yt-dlp.ps1               # yt-dlp interactive wrapper
├── fzf-enhance.ps1          # Coming soon
├── readline-enhance.ps1     # Coming soon
├── zoxide-enhance.ps1       # Coming soon
└── docs/
    ├── yt-dlp.md            # Detailed yt-dlp documentation
    └── ...                   # More docs
```

## 🎨 Design Philosophy

Every enhancement follows these principles:

1. **Non-Intrusive** - Original tool functionality stays intact
2. **Progressive Enhancement** - Basic usage stays simple, advanced features available
3. **Visual Clarity** - Colors, emojis, and formatting for better UX
4. **Cross-Platform** - Works on Windows, Linux, and macOS
5. **Zero Dependencies** - Only requires PowerShell and the original tool
6. **Lightweight** - Fast loading, minimal overhead

## 📝 Tool-Specific Documentation

- [yt-dlp Enhancement](docs/yt-dlp.md) - Video/audio downloader with interactive menus
- More coming soon...

## ❓ Troubleshooting

### Scripts not loading
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to RemoteSigned if needed (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Functions not available after installation
```powershell
# Reload profile
. $PROFILE

# Or restart PowerShell
```

### Path issues on Linux/macOS
Update the `$juicePath` variable in your profile to use `$HOME` instead of `$env:USERPROFILE`:
```powershell
$juicePath = "$HOME/.config/powershell/Scripts/TheSecretJuice"
```

## 🤝 Contributing

Got a CLI tool that needs the juice? Contributions welcome!

### Adding a New Enhancement

1. Fork the repository
2. Create your enhancement script: `tool-name.ps1`
3. Follow the design philosophy
4. Add documentation: `docs/tool-name.md`
5. Update this README
6. Submit a Pull Request

### Enhancement Template
```powershell
# tool-name.ps1
# Description of what this enhances

function tool-name {
    param([string]$args)
    
    # Banner
    Write-Host "Your Tool Enhancement" -ForegroundColor Cyan
    
    # Interactive menu
    # Error handling
    # Execute original tool
}

# Quick aliases (optional)
function tool-shortcut { ... }
```

## 💡 Planned Enhancements

Vote for what you want next by opening an issue!

- [ ] **fzf** - Fuzzy finder with presets
- [ ] **PSReadLine** - Enhanced editing
- [ ] **zoxide** - Smart directory jumper
- [ ] **ripgrep** - Interactive search
- [ ] **bat** - Enhanced file viewer
- [ ] **fd** - Interactive file finder
- [ ] Your suggestion here!

## 📜 License

MIT License - Use it, modify it, share it!

## 🙏 Acknowledgments

Thanks to all the amazing CLI tool developers who make our terminal lives better. This project just adds some sugar on top.

## 📞 Support

- 🐛 [Report Issues](https://github.com/mini-page/TheSecretJuice/issues)
- 💬 [Discussions](https://github.com/mini-page/TheSecretJuice/discussions)
- ⭐ Star if you find it useful!

---

**Making command-line tools feel like 2030** 💉✨
