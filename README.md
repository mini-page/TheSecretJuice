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
| **[Security](docs/modules/acllock-enhance.md)** | `lock` | Interactive ACL manager to lock/unlock files. |
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

## 🗺️ Internal Documentation Map

Explore our detailed guides and project reports:

### 💉 Steroid Modules
- **[yt-dlp-enhance](docs/modules/yt-dlp-enhance.md)** - Interactive media downloader.
- **[nav-enhance](docs/modules/nav-enhance.md)** - Supercharged navigation (zoxide + eza).
- **[git-enhance](docs/modules/git-enhance.md)** - Human-friendly Git wizard.
- **[fzf-enhance](docs/modules/fzf-enhance.md)** - Fuzzy finder for everything.
- **[cipher-enhance](docs/modules/cipher-enhance.md)** - Easy Windows EFS encryption.
- **[acllock-enhance](docs/modules/acllock-enhance.md)** - Interactive ACL permission manager.
- **[robocopy-enhance](docs/modules/robocopy-enhance.md)** - Smart file copying & mirroring.

### 🎨 Visual Enhancements (Optional)
- **[highContext Theme](docs/modules/theme-highcontext.md)** - The ultimate Oh-My-Posh theme for a "CLI 2030" look.

### 📦 Steroid Packs
- **[Security Pack](docs/packs/Security-Pack.md)** - Encryption and permission locking tools.
- **[Core Pack](docs/packs/Core-Pack.md)** - Essential helpers and profile management.
- **[Master Profile](docs/modules/master-profile.md)** - High-performance PowerShell profile template.
- **[Apps Pack](docs/packs/Apps-Pack.md)** - Software management and updates.
- **[Dev Pack](docs/packs/Dev-Pack.md)** - Tools for developers and shell analysis.
- **[Network Pack](docs/packs/Network-Pack.md)** - Connectivity diagnostics and tools.
- **[System Pack](docs/packs/System-Pack.md)** - Maintenance and optimization tools.

### 📊 Reports & Meta
- **[Project Status](Reports/PROJECT_STATUS.md)** - Current development progress and roadmap.
- **[Documentation Index](Reports/INDEX.md)** - Master index of all project documentation.
- **[Website README](Reports/Website/README.md)** - Details about the documentation site.
- **[Security Policy](Reports/Website/SECURITY.md)** - Security guidelines and reporting.

---

**Making CLI tools feel like 2030** 💉✨

*Built with ❤️ by [mini-page](https://github.com/mini-page)*
