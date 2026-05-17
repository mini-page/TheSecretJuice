# 🎨 highContext Theme (Oh-My-Posh)

The ultimate visual steroid for your terminal. Achieve the **"CLI 2030"** aesthetic with this highly customized Oh-My-Posh theme.

**Theme File:** `highContext.omp.json`

## ✨ Features

- 🖥️ **OS & Host Info**: Stylish OS icon and hostname display.
- 🐚 **Shell Detection**: Real-time shell type indicator.
- 📂 **Smart Pathing**: Full path display with folder icons and high-contrast separators.
- 🌿 **Git Integration**: Deep Git status, including branch icons, upstream tracking, and stash counts.
- 📦 **Environment Detection**: Automatic Node.js version detection with package manager icons.
- ⏰ **Contextual Time**: Date and time display with clock icons.
- 🔋 **System Health**: Battery percentage and charging status.
- ⚡ **Performance Tracking**: Command execution time in milliseconds.
- ✅ **Execution Status**: Visual success/failure indicators for the last command.
- 👤 **User Branding**: Bold username branding with a lightning bolt separator.

## 🚀 Installation (Optional)

This theme is **completely optional** but highly recommended for the full "Secret Juice" experience.

### 1. Install Oh-My-Posh
If you haven't already, install the Oh-My-Posh engine:
```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

### 2. Apply the Theme
Add the following line to your PowerShell `$PROFILE`:
```powershell
oh-my-posh init pwsh --config "$HOME\Documents\PowerShell\highContext.omp.json" | Invoke-Expression
```
*(Make sure to copy `highContext.omp.json` to the path specified above)*

### 3. Font Requirement
For the icons to render correctly, you **must** use a [Nerd Font](https://www.nerdfonts.com/).
- **Recommended:** *Meslo LGM NF* or *JetBrainsMono Nerd Font*.
- Set your terminal font to your chosen Nerd Font in settings.

## 🎨 Design Philosophy

The `highContext` theme was designed to provide **maximum situational awareness** without cluttering the screen. Every segment uses a distinct color from a professional palette:
- **Teal/Green**: System and Status
- **Deep Blue**: Shell and Tools
- **Earth/Sand**: File paths
- **Copper/Orange**: Git state
- **Magenta/Purple**: Time and User

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)
