# 📁 robocopy-enhance

Interactive PowerShell wrapper for robocopy with smart presets, logging, exclusions, and advanced utilities.

**Script file:** `robocopy-enhance.ps1`

## 🆕 Features

- **🎯 Smart Presets** - Mirror, Sync, Backup, Fast, Verify, Incremental modes
- **📝 Logging** - Optional file logging with timestamps
- **🚫 Exclusions** - Pre-built filters for dev folders and system files
- **💾 Settings Memory** - Save your preferences, skip repetitive prompts
- **📊 Statistics** - Detailed directory stats and comparisons
- **⏰ Scheduling** - Create scheduled backup tasks
- **👁️ Watch Mode** - Continuous monitoring and auto-sync
- **🛡️ Safety Review** - Automatic detection of dangerous operations (Mirror, Move, Purge)
- **🛑 Destruction Protection** - Required 'DELETE' confirmation for high-risk syncs
- **🎨 Beautiful UI** - Colorful, emoji-rich interfaces with smart error handling

## 🚀 Quick Start

```powershell
# Interactive mode (easiest)
robocopy

# Quick mirror sync
robo-mirror C:\Source D:\Backup

# Quick backup (skip older)
robo-backup C:\Data D:\Backup

# Compare directories
robo-diff C:\Folder1 C:\Folder2

# Show help
robo-help
```

## 📋 Interactive Menu Options

When you run `robocopy` without arguments, you get an interactive menu:

### Copy Mode Presets:
1. **Mirror** - Delete extra files in destination (`/MIR`)
2. **Sync** - Keep all subdirs, no deletions (`/E`)
3. **Backup** - Skip older files (`/MIR /XO`)
4. **Fast** - Minimal logging, max threads (`/E /MT:16`)
5. **Verify** - Copy with verification (`/E /V /ETA`)
6. **Incremental** - Skip older files only (`/E /XO`)
7. **Custom** - Enter your own robocopy flags

### Logging Options:
1. **Console only** - No log file
2. **Log to file** - Overwrite existing log
3. **Append to file** - Add to existing log

Logs are saved to: `%USERPROFILE%\Documents\robocopy-logs\`

### Exclusion Filters:
1. **No exclusions** - Copy everything
2. **Dev folders** - Exclude: `node_modules, .git, .svn, bin, obj`
3. **System/temp files** - Exclude: `*.tmp, *.log, Thumbs.db, .DS_Store`
4. **Both** - Exclude dev folders + system files
5. **Custom** - Specify your own exclusions

### Preview & Execution:
1. **Start copy** - Begin the actual copy operation
2. **Dry run** - See what would be copied without doing it (`/L`)
3. **Show stats** - Display detailed statistics about source and destination
4. **Cancel** - Abort the operation

## 🎯 Quick Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `robo-mirror` | `robo-mirror <src> <dst>` | Mirror sync (deletes extras) |
| `robo-backup` | `robo-backup <src> <dst>` | Backup mode (skip older files) |
| `robo-sync` | `robo-sync <src> <dst>` | Sync without deletions |
| `robo-fast` | `robo-fast <src> <dst>` | Fast copy with minimal logging |
| `robo-verify` | `robo-verify <src> <dst>` | Copy with verification |
| `robo-diff` | `robo-diff <src> <dst>` | Compare two directories |
| `robo-stats` | `robo-stats <path>` | Show directory statistics |
| `robo-schedule` | `robo-schedule <src> <dst> [time]` | Create scheduled backup task |
| `robo-watch` | `robo-watch <src> <dst> [interval]` | Watch and auto-sync changes |

## 💡 Examples

### Basic Usage

```powershell
# Interactive mode
robocopy

# Quick mirror (identical copy)
robo-mirror C:\Projects D:\Backup\Projects

# Backup without deleting destination files
robo-sync C:\Documents E:\Backup\Documents

# Fast copy for large datasets
robo-fast D:\Videos E:\Media\Videos
```

### Advanced Usage

```powershell
# Compare before copying
robo-diff C:\OldData C:\NewData

# Get statistics
robo-stats C:\MyFolder

# Schedule daily backup at 2 AM
robo-schedule C:\Important D:\Backup\Important 02:00

# Watch and sync every 30 seconds
robo-watch C:\DevFolder D:\Backup\DevFolder 30

# Verified copy with statistics first
robo-stats C:\Source
robo-verify C:\Source D:\Destination
```

### With Settings Memory

```powershell
# First run - configure your preferences
robocopy
# Choose preset, logging, exclusions
# Save settings when prompted

# Next runs - use saved settings instantly
robocopy
# Select option 1 to use saved settings
# Or option 3 for quick defaults
```

## 📊 Understanding Exit Codes

Robocopy uses bit-flag exit codes:

| Code | Meaning |
|------|---------|
| 0 | No changes needed - files already match |
| 1 | Files copied successfully |
| 2 | Extra files/directories detected in destination |
| 4 | Mismatches detected between source and destination |
| 8+ | Errors occurred during copy |

**Combined codes:** Exit code 3 means both 1 and 2 (files copied + extras found)

## 🎯 Preset Details

### Mirror (`/MIR`)
- **Use case:** Exact replica of source
- **Warning:** Deletes files in destination that don't exist in source
- **Best for:** Backups where destination should match source exactly
- **Flags:** `/MIR /R:3 /W:5 /MT:8 /V`

### Sync (`/E`)
- **Use case:** Copy all subdirectories
- **Safe:** Never deletes files from destination
- **Best for:** Accumulative backups
- **Flags:** `/E /R:3 /W:5 /MT:8 /V`

### Backup (`/MIR /XO`)
- **Use case:** Incremental backups
- **Smart:** Skips files that are older in source
- **Best for:** Daily/weekly backups
- **Flags:** `/MIR /DCOPY:DAT /COPY:DAT /R:3 /W:5 /MT:8 /XO /V`

### Fast (`/MT:16`)
- **Use case:** Quick transfers
- **Speed:** Uses 16 threads, minimal logging
- **Best for:** Large datasets where speed matters
- **Flags:** `/E /R:1 /W:1 /MT:16 /NFL /NDL /NJH /NJS`

### Verify (`/V`)
- **Use case:** Critical data that needs verification
- **Reliable:** Verifies each file after copy
- **Best for:** Important documents, databases
- **Flags:** `/E /R:3 /W:5 /MT:8 /V /ETA`

### Incremental (`/XO`)
- **Use case:** Copy only new or changed files
- **Efficient:** Skips files that haven't changed
- **Best for:** Regular syncs of actively changing data
- **Flags:** `/E /XO /R:3 /W:5 /MT:8 /V`

## 🚫 Exclusion Patterns

### Development Folders
Automatically excludes:
- `node_modules` - Node.js packages
- `.git` - Git repository
- `.svn` - SVN repository
- `bin` - Binary output
- `obj` - Object files

### System/Temp Files
Automatically excludes:
- `*.tmp` - Temporary files
- `*.log` - Log files
- `Thumbs.db` - Windows thumbnail cache
- `Desktop.ini` - Windows folder settings
- `.DS_Store` - macOS folder settings

### Custom Exclusions
Specify your own patterns:
```powershell
# During interactive mode, choose option 5
# Then enter patterns like:
# Folders: cache temp downloads
# Files: *.bak *.old *.backup
```

## ⏰ Scheduled Backups

Create automated backup tasks:

```powershell
# Daily backup at 2 AM
robo-schedule C:\Important D:\Backup\Important 02:00

# Daily backup at 11 PM
robo-schedule C:\Projects D:\Backup\Projects 23:00

# View/modify in Task Scheduler
taskschd.msc
```

The scheduled task will:
- Run daily at specified time
- Use mirror mode by default
- Run even if user is not logged in (requires admin)
- Send notifications on failure

## 👁️ Watch Mode

Continuously monitor and sync changes:

```powershell
# Sync every 60 seconds (default)
robo-watch C:\ActiveFolder D:\BackupFolder

# Sync every 30 seconds
robo-watch C:\DevFolder D:\BackupFolder 30

# Press Ctrl+C to stop
```

**Use cases:**
- Real-time backup of active work
- Monitoring shared folders
- Development environment syncing
- Cloud storage local mirrors

## 📝 Logging

### Log Files
Saved to: `%USERPROFILE%\Documents\robocopy-logs\`

Format: `robocopy_YYYYMMDD_HHMMSS.log`

Example: `robocopy_20250121_143052.log`

### What's Logged:
- Source and destination paths
- Files copied, skipped, failed
- Directories created
- Bytes transferred
- Speed and time statistics
- Error messages

### View Logs
```powershell
# Open log directory
explorer "$env:USERPROFILE\Documents\robocopy-logs"

# View latest log
notepad (Get-ChildItem "$env:USERPROFILE\Documents\robocopy-logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

## 🔧 Common Flags Reference

| Flag | Description |
|------|-------------|
| `/E` | Copy subdirectories, including empty ones |
| `/MIR` | Mirror directory tree (includes deletions) |
| `/MT:n` | Multi-threaded copying (n = threads, default 8) |
| `/R:n` | Number of retries on failed copies |
| `/W:n` | Wait time between retries (seconds) |
| `/XO` | Exclude older files (skip if source is older) |
| `/XF` | Exclude files matching pattern |
| `/XD` | Exclude directories matching pattern |
| `/V` | Verbose output with verification |
| `/NP` | No progress - don't display percentage |
| `/LOG:file` | Write log to file (overwrite) |
| `/LOG+:file` | Write log to file (append) |
| `/L` | List only - don't copy, delete, or timestamp |
| `/ETA` | Show estimated time of arrival |
| `/DCOPY:DAT` | Copy directory attributes, timestamps |
| `/COPY:DAT` | Copy file data, attributes, timestamps |

## ❓ Troubleshooting

### "Access Denied" Errors
```powershell
# Run PowerShell as Administrator
# Or adjust NTFS permissions on source/destination
icacls "C:\Path" /grant:r "Username:(OI)(CI)F" /T
```

### Large File Handling
```powershell
# Use fast mode for big files
robo-fast C:\LargeData D:\Backup

# Or adjust retries/wait time in custom mode
# Flags: /R:10 /W:30  (10 retries, 30 sec wait)
```

### Network Paths
```powershell
# Use UNC paths
robo-mirror "C:\Local" "\\Server\Share\Backup"

# Map network drive first if needed
net use Z: \\Server\Share /persistent:yes
robo-mirror "C:\Local" "Z:\Backup"
```

### Performance Tuning
```powershell
# Increase threads for SSDs
# Custom flags: /MT:32

# Decrease threads for HDDs to avoid thrashing
# Custom flags: /MT:4

# Disable logging for max speed
robo-fast C:\Source D:\Dest
```

## 🎓 Best Practices

### Daily Backups
```powershell
# Schedule with backup preset
robo-schedule C:\Important D:\Backup 02:00

# Or use incremental for speed
# Manual: robocopy with preset 6 (Incremental)
```

### Project Syncing
```powershell
# Exclude dev folders
robocopy
# Choose Sync preset (2)
# Choose Dev exclusions (2)
```

### Media Libraries
```powershell
# Use fast mode
robo-fast D:\Photos E:\Backup\Photos

# Or mirror if you want exact replica
robo-mirror D:\Photos E:\Backup\Photos
```

### Disaster Recovery
```powershell
# Full mirror backup
robo-mirror C:\ D:\SystemBackup

# Exclude system files
# During interactive mode:
# - Choose Mirror preset
# - Choose System exclusions
```

## 💾 Settings Management

### Save Settings
During interactive mode, you'll be prompted to save:
- Preset choice
- Logging preference
- Exclusion filters

Saved to: `%USERPROFILE%\.robocopy-settings.json`

### Load Settings
Next time you run `robocopy`:
1. Choose "Use saved settings" (option 1)
2. All previous choices are applied automatically
3. No repeated prompts!

### Reset Settings
```powershell
robo-reset-settings
```

## 🔐 Security Notes

### Sensitive Data
- Always test with dry run first (`/L` flag)
- Review logs for unexpected changes
- Consider encryption for backup destinations
- Use NTFS permissions to protect backup folders

### Network Backups
- Use VPN for remote backups
- Verify credentials before scheduling tasks
- Monitor logs for failed authentication
- Consider SMB signing for network paths

## 🚀 Performance Tips

1. **Use SSDs:** Enable higher thread counts (`/MT:32`)
2. **Network copies:** Reduce threads to avoid saturation (`/MT:4`)
3. **Large files:** Use fast mode for less overhead
4. **Many small files:** Use verify mode to ensure integrity
5. **Exclude unnecessary:** Always exclude temp/cache folders

## 📚 Command Reference

```powershell
# Show all commands
robo-help

# Interactive mode
robocopy

# Quick commands
robo-mirror <src> <dst>
robo-backup <src> <dst>
robo-sync <src> <dst>
robo-fast <src> <dst>
robo-verify <src> <dst>

# Analysis
robo-diff <src> <dst>
robo-stats <path>

# Advanced
robo-schedule <src> <dst> [time]
robo-watch <src> <dst> [interval]
robo-reset-settings
```

## 🌟 Pro Tips

1. **Test First:** Always use `robo-diff` before `robo-mirror`
2. **Check Stats:** Use `robo-stats` to estimate copy time
3. **Save Settings:** Answer "Y" when prompted to save preferences
4. **Schedule Wisely:** Schedule backups during low-activity hours
5. **Monitor Logs:** Check logs after scheduled tasks complete
6. **Dry Run:** Use option 2 in preview menu to test without copying

## 🔄 Workflow Examples

### New Backup Setup
```powershell
# 1. Check what you're backing up
robo-stats C:\Important

# 2. Compare first (if destination exists)
robo-diff C:\Important D:\Backup\Important

# 3. Test run
robocopy  # Choose dry run option

# 4. Execute
robocopy  # Choose start copy

# 5. Schedule for automation
robo-schedule C:\Important D:\Backup\Important 02:00
```

### Development Workflow
```powershell
# 1. Initial sync (exclude dev folders)
robocopy
# Source: C:\Projects
# Dest: D:\Backup\Projects
# Preset: Sync (2)
# Exclusions: Dev folders (2)
# Save settings: Y

# 2. Daily quick syncs (use saved settings)
robocopy  # Option 1 (use saved)

# 3. Watch mode during active development
robo-watch C:\Projects\Active D:\Backup\Active 60
```

### Media Library Management
```powershell
# 1. Check size first
robo-stats D:\Photos

# 2. Fast initial copy
robo-fast D:\Photos E:\Backup\Photos

# 3. Schedule weekly updates
robo-schedule D:\Photos E:\Backup\Photos 23:00
```

## 📖 Further Reading

- [Official Robocopy Documentation](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy)
- [Robocopy Exit Codes Explained](https://ss64.com/nt/robocopy-exit.html)
- [Windows Backup Best Practices](https://docs.microsoft.com/en-us/windows-server/storage/backup/backup-overview)

## 🐛 Known Issues

### Issue: "Too many retries"
**Solution:** Adjust retry settings in custom mode
```powershell
# Custom flags: /R:10 /W:30
```

### Issue: Scheduled task not running
**Solution:** Check Task Scheduler settings
- Open Task Scheduler (`taskschd.msc`)
- Find your task under "Task Scheduler Library"
- Right-click > Properties
- Ensure "Run whether user is logged on or not" is checked
- Verify account has proper permissions

### Issue: High CPU usage
**Solution:** Reduce thread count
```powershell
# Custom flags: /MT:4
# Or use robo-backup instead of robo-fast
```

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)

Need help? [Open an issue](https://github.com/mini-page/TheSecretJuice/issues)
