# 🔍 fzf-enhance

Fuzzy finder with smart presets and interactive previews. Quickly search files, manage processes, and explore command history.

**Script file:** `fzf-enhance.ps1`

## 🆕 Features

- **📂 Smart File Search** - Fuzzy search files with syntax-highlighted previews (requires `bat`).
- **⚙️ Process Killer** - Interactive process manager with resource statistics.
- **📚 History Search** - Search through PowerShell history and execute commands instantly.
- **💾 Settings Memory** - Persists your preview preferences and default editor choices.
- **🎨 Beautiful UI** - Colorful, emoji-rich interfaces following the Secret Juice theme.

## 🚀 Quick Start

```powershell
# Main interactive menu
fz

# Direct file search
fzf-file

# Show help
fzf-help
```

## 📋 Interactive Menu Options

When you run `fz`, you get an interactive menu:

### 1. 📂 File Search (with Preview)
- **Fuzzy Search:** Type to filter files in the current directory and subdirectories.
- **Preview:** View file contents in a side pane. If `bat` is installed, it provides syntax highlighting.
- **Actions:**
    1. **Open with Default Editor** (e.g., VS Code).
    2. **Open with Notepad**.
    3. **Copy path to clipboard**.

### 2. ⚙️ Process Killer
- Lists all running processes with PID, CPU, and Working Set.
- Filter by name or ID.
- Press **Enter** on a process and confirm to terminate it.

### 3. 📚 Command History
- Loads your unique PowerShell command history.
- Use fuzzy search to find a previous command.
- Press **Enter** to instantly execute the selected command.

### 4. 🛠️ Configure Settings
- **Toggle Previews:** Enable or disable the fzf preview window.
- **Set Default Editor:** Define the command used to open files (e.g., `code`, `vim`, `subl`).

## 🎯 Quick Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `fz` | `fz [query]` | Open main interactive menu |
| `fzf-file` | `fzf-file [query]` | Launch fuzzy file search directly |
| `fzf-help` | `fzf-help` | Show this help menu |

## 💡 Examples

### Searching Files
```powershell
fz "config"       # Opens fzf with 'config' pre-filled in file search
fzf-file ".ps1"   # Search only for PowerShell scripts
```

### Cleaning Up Processes
```powershell
fz                # Choose option 2
# Type 'chrome' to find all Chrome processes
# Select the one using too much RAM and press Enter
```

### Re-executing Commands
```powershell
fz                # Choose option 3
# Search for that long docker command you ran yesterday
# Press Enter to run it again
```

## 📋 Requirements

- **[fzf](https://github.com/junegunn/fzf)** - Required for all features.
- **[bat](https://github.com/sharkdp/bat)** - Optional, for syntax-highlighted previews.
- **[PSReadLine](https://github.com/PowerShell/PSReadLine)** - Required for Command History features.

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)
