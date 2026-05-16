# 💉 TheSecretJuice

**PowerShell steroids for your favorite command-line tools**

Transform boring CLI tools into interactive, colorful, user-friendly experiences. **Pick what you need, skip what you don't.**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ What You Get

- 🎨 **Interactive menus** - No more memorizing cryptic flags.
- 🍪 **Smart features** - Cookie support, download archives, error detection.
- 🎯 **Selective Install** - Choose exactly which tool packs you want.
- 💾 **Settings memory** - Save your preferences, skip repetitive prompts.
- 🌈 **Beautiful UI** - Colorful, emoji-rich interfaces for every tool.

## 🚀 One-Command Install

**The interactive wizard will guide you through choosing your steroids:**

```powershell
iwr https://raw.githubusercontent.com/mini-page/TheSecretJuice/main/install.ps1 | iex
```

1.  **Select Tools:** Choose from Media, Navigation, Dev, System, and more.
2.  **Dependency Check:** If a tool requires something (like `fzf` or `yt-dlp`), the installer provides a **Manual** with download links.
3.  **Restart & Enjoy:** Reload your profile (`. $PROFILE`) and you're ready!

## 📦 Available Steroid Packs

| Pack | Main Command | What it does |
|------|--------------|--------------|
| **[Media](docs/yt-dlp-enhance.md)** | `yt-dlp` | Download videos/audio with menus, cookies, archives. |
| **[Navigation](docs/nav-enhance.md)** | `zi` | Smart navigation with zoxide + eza, bookmarks. |
| **[Search](docs/fzf-enhance.md)** | `fz` | Fuzzy finder for files, processes, and history. |
| **[Dev](docs/git-enhance.md)** | `g` | Interactive Git with Conventional Commit wizard. |
| **[System](docs/modules.html)** | `optimize` | Maintenance, cleanup, and deep system specs. |
| **[Network](docs/modules.html)** | `net-works` | Diagnostics, public IP info, and connectivity tests. |

## ❓ How to use it?

Once installed, just type:
```powershell
juice-help          # Show the Master Help menu
juice-help git      # Show specific help for Git steroids
yt-help             # Every tool has its own dedicated help
```

## 🛠️ Contribution

Got a CLI tool that needs steroids? [Check out CONTRIBUTING.md](CONTRIBUTING.md) for our module template and UI guidelines!

---

**Making CLI tools feel like 2030** 💉✨

*Built with ❤️ by [mini-page](https://github.com/mini-page)*
