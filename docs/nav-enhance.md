# 🧭 nav-enhance

Supercharged navigation and listing for PowerShell using zoxide + eza.

## 🚀 Quick Start

```powershell
# Jump and list
zz projects

# Interactive fuzzy jump
zi

# Jump to bookmark
bm work

# Show help anytime
nav-help
```

## 📋 Command Reference

### 🎯 Navigation

| Command | Description | Example |
|---------|-------------|---------|
| `zz <query>` | Jump to directory and list | `zz documents` |
| `zi` | Interactive fuzzy jump with preview | `zi` |
| `zc <query>` | Jump and open in VSCode | `zc myproject` |
| `ze <query>` | Jump and open in Explorer/Finder | `ze downloads` |
| `zn` | Numbered list (pick 1-10) | `zn` → `3` |
| `zx` | Jump with action menu | `zx` |
| `z-` | Go back to previous directory | `z-` |
| `..` / `...` / `....` | Navigate up 1/2/3 levels | `...` |

### 📂 Listing Basics

| Command | Description | Output |
|---------|-------------|--------|
| `lb` | Basic list with icons | Simple view |
| `ll` | Long format with details | Size, date, permissions |
| `la` | All files (including hidden) | Shows `.git`, `.env`, etc. |
| `lt` | Tree view (2 levels) | Visual hierarchy |
| `ltt` | Deep tree (4 levels) | Full structure |
| `ld` | Detailed with git status | Everything |

### 🔄 Sorting

| Command | Sorts By | Use Case |
|---------|----------|----------|
| `lz` | Size (largest first) | Find big files |
| `lm` | Modified time (newest) | Recent changes |
| `lc` | Created time | Original files |

### 🔍 Filtering

| Command | Shows | Example |
|---------|-------|---------|
| `ldo` | Only directories | Folder structure |
| `lf` | Only files | No folders |
| `lcode` | Code files (.ps1, .py, .js, etc.) | Development |
| `lmedia` | Media (.jpg, .mp4, .mp3, etc.) | Images/videos |
| `ldoc` | Documents (.pdf, .docx, etc.) | Papers/docs |
| `lr` | Recent files (24h) | What changed today |
| `lbig` | Large files (10MB+) | Disk hogs |

### 📚 Bookmarks

| Command | Description | Example |
|---------|-------------|---------|
| `bm-add [name]` | Bookmark current dir | `bm-add work` |
| `bm [name]` | Jump to bookmark | `bm work` |
| `bm` | Interactive picker | Shows all, pick one |
| `bm-list` | List all bookmarks | View saved |
| `bm-rm <name>` | Remove bookmark | `bm-rm oldproject` |

### 🔧 Utilities

| Command | Description | Use Case |
|---------|-------------|----------|
| `pj [path]` | Find git projects | Quick project access |
| `fn <pattern>` | Find folder by name | `fn test` |
| `lst` | Directory statistics | Size, file count |
| `lg` | Git-focused listing | See repo status |
| `cdg <path>` | Navigate + git status | Quick git check |

## 💡 Common Workflows

### Quick Project Access
```powershell
# Find projects interactively
pj ~/code

# Or jump if you remember the name
zz myproject
```

### File Management
```powershell
# Find large files
lbig

# Check recent changes
lr

# Show only code files
lcode
```

### Bookmarking Workflow
```powershell
# At your work directory
bm-add work

# At your personal projects
bm-add personal

# Later, jump instantly
bm work
bm personal
```

### Development Workflow
```powershell
# Jump and open in VSCode
zc myapp

# Or jump with git status
zz myapp
lg

# Or navigate and check git
cdg ~/projects/myapp
```

### Exploration
```powershell
# Interactive fuzzy search
zi

# Preview directories before jumping
zx  # Then choose action
```

## 🎯 Power User Tips

**Chain Commands:**
```powershell
# Jump, list code files, open editor
zz project; lcode; code .
```

**Quick Stats:**
```powershell
# Before cleanup
lst
# Do cleanup
# After
lst
```

**Find and Jump:**
```powershell
# Search for folder name
fn test
# Pick from results, auto-navigate
```

**Bookmark Your Stack:**
```powershell
# Save common locations
bm-add dotfiles
bm-add scripts
bm-add downloads
bm-add temp

# Quick access forever
bm dotfiles
```

**Recent Work:**
```powershell
# Show today's changes
lr

# Show last 10 visited dirs
zn
```

## 🔧 Advanced Usage

### VSCode Integration
```powershell
# Jump and code
zc projectname

# Or from interactive
zi  # Then press 2 for VSCode
```

### Explorer Integration
```powershell
# Open in file manager
ze downloads

# Or after jumping
zz documents
ze .
```

### Git Workflows
```powershell
# Git-focused listing
lg

# Navigate with status
cdg ~/repo

# Detailed git tree view
ld
```

### Project Discovery
```powershell
# Find all git repos in home
pj ~

# Find in specific path
pj ~/code

# Fuzzy select and jump
```

## 📊 Understanding Output

### Color Meanings
- 🟦 **Cyan** = Directories
- 🟩 **Green** = Executables
- 🟨 **Yellow** = Modified recently
- ⚪ **White** = Regular files
- 🟥 **Red** = Important/System files

### Icons Guide
- 📁 Folder
- 📄 Text file
- 🎵 Audio
- 🎬 Video
- 🖼️ Image
- 📦 Archive
- 🔧 Config
- 🐍 Python
- 📜 Script

## ❓ Troubleshooting

### Commands not found
```powershell
# Ensure tools are installed
zoxide --version
eza --version
fzf --version

# Reload profile
. $PROFILE
```

### fzf not working
Install fzf:
```powershell
# Windows (scoop)
scoop install fzf

# Or chocolatey
choco install fzf

# Linux/Mac
# Already in most package managers
```

### Bookmarks not saving
Check file permissions:
```powershell
$bookmarksFile = "$env:USERPROFILE\.nav_bookmarks.json"
Test-Path $bookmarksFile
```

### Zoxide not tracking
Add directories manually:
```powershell
za  # Add current directory
```

## 🎨 Customization

### Change Default Tree Depth
Edit `nav-enhance.ps1`:
```powershell
# Change from level=2 to level=3
function lt { eza --icons --tree --level=3 @Args }
```

### Add Custom Filters
Add your own listing functions:
```powershell
# Only Python files
function lpy {
    eza --icons -lha | Select-String -Pattern '\.py$'
}
```

### Custom Bookmarks Location
Change in script:
```powershell
$bookmarksFile = "C:\MyPath\.bookmarks.json"
```

## 📝 Examples

**Daily Workflow:**
```powershell
# Morning: Jump to work projects
bm work
lg  # Check git status

# Code review: Find recent changes
lr

# Cleanup: Find large files
lbig

# End of day: Bookmark new project
bm-add newfeature
```

**Project Setup:**
```powershell
# Find the project
pj ~/code

# Check structure
ltt

# Open in editor
code .
```

**File Organization:**
```powershell
# Check media files
lmedia

# Sort by size
lz

# Move large files elsewhere
```

## 🚀 Performance Tips

- Use `lb` for quick checks (fastest)
- Use `lt` instead of `ltt` for large directories
- Bookmark frequently accessed paths
- Use `zn` for quick recent access
- `lcode` is faster than `la` in code directories

## 🔗 Integration

Works great with:
- **VSCode** - `zc` command
- **Git** - `lg`, `cdg` commands
- **Ripgrep** - `lgrep` command
- **File managers** - `ze` command

## 📚 Related Commands

Need to search file contents? Use:
```powershell
rg "search term"  # Then navigate with zz
```

Need to find files? Use:
```powershell
fd "pattern"  # Then use with eza
```

---

**Need help?** 
- Type `nav-help` in your terminal
- Open issue at [github.com/mini-page/TheSecretJuice](https://github.com/mini-page/TheSecretJuice/issues)