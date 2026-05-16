# 🤝 Contributing to TheSecretJuice

First off, thank you for considering contributing to **TheSecretJuice**! It's people like you that make CLI tools feel like they're from 2030. 💉✨

## 🌈 How Can I Contribute?

### 💡 Suggesting Enhancements
Got a CLI tool that's too cryptic? A flag that you can never remember? [Open a Feature Request](https://github.com/mini-page/TheSecretJuice/discussions) and let's juice it up!

### 🐛 Reporting Bugs
Found a bug? [Open an Issue](https://github.com/mini-page/TheSecretJuice/issues) with:
1. Your OS and PowerShell version (`$PSVersionTable`)
2. Steps to reproduce
3. Expected vs. Actual behavior

### 🛠️ Creating a New "Steroid"
We love new modules! To keep things consistent, please follow these guidelines:

1.  **Language:** PowerShell 5.1+ (stay compatible with PS Core if possible).
2.  **UI:** Use the magenta/cyan banner style and emoji-rich feedback.
3.  **Persistence:** Use JSON files for saving settings in `$env:USERPROFILE`.
4.  **Documentation:** Add your module to `docs/assets/data/modules.json` and create a `.md` file in `docs/`.

---

## 📝 Module Template

Use this structure for your new `.ps1` script in the `Steroids/` folder:

```powershell
# [tool-name]-enhance.ps1
# Part of TheSecretJuice

# 1. Settings Management
$settingsFile = "$env:USERPROFILE\.[tool]-settings.json"

function Load-Settings {
    if (Test-Path $settingsFile) {
        try { return Get-Content $settingsFile | ConvertFrom-Json } catch { return $null }
    }
    return $null
}

function Save-Settings {
    param($settings)
    $settings | ConvertTo-Json | Out-File $settingsFile -Force
    Write-Host "   OK. Settings saved!" -ForegroundColor Green
}

# 2. Main Interactive Function
function [tool-name] {
    param([string]$input)
    
    # Banner
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       [TOOL] Interactive     ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Logic goes here...
}

# 3. Quick Aliases
Set-Alias -Name "[alias]" -Value "[tool-name]"
```

---

## 🚀 Future Roadmap (Juice Pipeline)

We're currently focusing on these areas:
- 🎯 **v2.1:** `fzf-enhance`, `git-enhance`, and Theme System.
- 🌌 **The Backlog:** `docker-enhance`, `npm-enhance`, `ssh-enhance`.

## 📜 Code of Conduct
Be kind, be helpful, and keep the code clean. We're all here to build something awesome.

**Happy Coding!** 🚀
