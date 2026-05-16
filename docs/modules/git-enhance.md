# 🌿 git-enhance

Human-friendly Git wrapper for interactive version control. Includes guided conventional commits, fuzzy branch switching, and beautiful logs.

**Script file:** `git-enhance.ps1`

## 🆕 Features

- **📊 Smart Status** - Colored status overview with an interactive `fzf`-based staging interface.
- **✍️ Guided Commit** - Conventional Commit wizard (feat, fix, docs, etc.) to keep your history clean.
- **🔀 Branch Switcher** - Use `fzf` to quickly search and switch between local and remote branches.
- **📜 Beautiful Logs** - Highly readable, color-coded Git graph visualizations.
- **🚀 One-Click Sync** - Combined Pull/Push operations with a single selection.
- **💾 Settings Memory** - Save your preferred remotes and auto-push behaviors.

## 🚀 Quick Start

```powershell
# Main interactive menu
g

# Smart status & staging
g-status

# View beautiful log graph
g-log

# Show help
git-help
```

## 📋 Interactive Menu Options

When you run `g` in a Git repository, you get an interactive menu:

### 1. 📊 Status & Interactive Stage
- Shows `git status -sb` for a concise overview.
- Prompts to stage all changes (`y`), skip (`n`), or select interactively (`i`).
- Interactive mode uses `fzf` for multi-selecting files (using **Tab**).

### 2. ✍️ Guided Commit (Conventional)
- Choose from common commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`.
- Optional scope input (e.g., `ui`, `api`).
- Prompts for a mandatory commit message.
- Enforces a clean format: `type(scope): message`.
- Optional auto-push after successful commit.

### 3. 🔀 Branch Switcher (FZF)
- Lists all local and remote branches.
- Fuzzy search to find the target branch.
- Automatically handles remote tracking if needed.

### 4. 📜 Beautiful Log Graph
- Displays a condensed, colorful `--graph` view.
- Uses `fzf` for scrolling and searching through commits.

### 5. 🚀 Sync (Pull & Push)
- Automatically pulls latest changes from the configured remote.
- Pushes your commits to the current branch.

### 6. 🛠️ Configure Settings
- Set **Auto-Push** behavior: `Ask` (default), `Always`, or `Never`.
- Define the default remote name (e.g., `origin`).

## 🎯 Quick Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `g` | `g` | Open main interactive menu |
| `g-status` | `g-status` | View status and stage files |
| `g-log` | `g-log` | Show colored git graph |
| `git-help` | `git-help` | Show this help menu |

## 💡 Examples

### Making a Conventional Commit
```powershell
g-status           # Stage your changes
g                  # Choose option 2
# Select 'feat'
# Enter scope: 'auth'
# Enter message: 'add JWT support'
# Confirm and push
```

### Switching Branches
```powershell
g                  # Choose option 3
# Type 'main' or 'feat/' to find your branch
# Press Enter to checkout
```

## 📋 Requirements

- **[git](https://git-scm.com/)** - Required.
- **[fzf](https://github.com/junegunn/fzf)** - Required for interactive staging and branch switching.

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)
