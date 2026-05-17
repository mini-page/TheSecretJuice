# 🚀 Master Profile (PowerShell)

A high-performance, optimized PowerShell profile designed to be the foundation of "The Secret Juice" ecosystem. It focuses on speed, reliability, and automated maintenance.

**Profile Template:** `Microsoft.PowerShell_profile.ps1`

## ✨ Features

- ⏱️ **Fast Boot**: Measures load time and uses caching for directory scans.
- 🧊 **Lazy Loading**: Only loads heavy modules (like `PSWindowsUpdate`) when you actually call them.
- 🤫 **Silent Startup**: Suppresses progress bars and noise during the boot sequence.
- 🛡️ **Safe Imports**: Gracefully handles missing modules without breaking the terminal.
- 🧊 **Minimal Mode**: Launch with `$env:PWSH_MINIMAL=1` for a raw, high-speed shell.
- 💾 **Steroid Auto-Load**: Automatically detects and loads any `*-enhance.ps1` script from your Steroids folder.
- 🛠️ **Built-in Maintenance**: One-command module installation and updates.
- 📊 **Stats Dashboard**: View load times and version info on startup.

## 🚀 Installation

### 1. Locate your profile
Run this in PowerShell to find your profile path:
```powershell
$PROFILE
```

### 2. Backup existing profile
If you already have a profile, back it up using our helper (if installed):
```powershell
profile backup
```
Or manually copy it to a safe location.

### 3. Apply the Master Profile
Copy the content of `Microsoft.PowerShell_profile.ps1` into your `$PROFILE` path.

### 4. Configuration
Ensure the paths in the profile match your installation:
- **Steroids Path**: Defaults to `$HOME\Documents\PowerShell\Steroids`.
- **Theme Path**: Defaults to `$env:USERPROFILE\Documents\PowerShell\highContext.omp.json`.

## 🛠️ Maintenance Commands

The Master Profile includes global functions to keep your environment healthy:

- `Install-PwshModules`: Installs the recommended suite of modules for the best experience.
- `Update-PwshModules`: Updates all installed modules to their latest versions.
- `Profile-Stats`: Shows detailed load time information.
- `__LogOk`/`__LogWarn`: Internal logging for debugging startup issues.

## 🧪 Minimal Mode
Need maximum speed for a quick task?
```powershell
$env:PWSH_MINIMAL=1; pwsh
```
This skips the entire theme and module loading sequence for an instant-on experience.

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)
