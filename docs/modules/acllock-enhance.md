# 🔒 acllock-enhance

Interactive ACL (Access Control List) Manager for Windows - Easily lock and unlock files or folders with password protection.

**Script file:** `acllock-enhance.ps1`

## 🆕 What's New

- **🔒 Interactive Lock/Unlock** - Simple TUI for managing file permissions
- **🔑 Password Protection** - Secure your lock/unlock operations with a custom password
- **🛡️ Inheritence Management** - Automatically handles permission inheritance
- **💾 ACL Backups** - Safely backup permissions before locking, restore them on unlock
- **📊 Status Checker** - Quickly see if a path is locked or accessible
- **⚡ Quick Aliases** - Fast commands for power users (`lock`, `acl`)

## 🚀 Quick Start

```powershell
# Interactive mode (easiest)
acllock

# Quick lock a file/folder
acllock lock C:\SecretFolder

# Quick unlock
acllock unlock C:\SecretFolder

# Check status
acllock status C:\SecretFolder

# Show help
acl-help
```

## 📋 Menu Options

| Option | Feature | What it does |
|--------|---------|--------------|
| 1 | **Lock** | Backs up ACL, disables inheritance, and denies Everyone access |
| 2 | **Unlock** | Removes Deny rule, restores inheritance, and original ACL |
| 3 | **Status** | Checks if the 'Everyone: Deny' rule is present |
| 4 | **Help** | Displays the command reference |
| 5 | **Exit** | Closes the interactive menu |

## 🔐 How it Works

### Locking Process
1. **Backup**: Saves the current ACL to `$env:LOCALAPPDATA\acllock\backup`.
2. **Inheritance**: Removes inherited permissions to ensure strict control.
3. **Grant**: Ensures Administrators maintain Full Control.
4. **Deny**: Adds a "Deny" rule for "Everyone", which takes precedence in Windows.

### Unlocking Process
1. **Remove Deny**: Removes the "Everyone: Deny" rule.
2. **Restore Inheritance**: Re-enables permission inheritance.
3. **Restore ACL**: Applies the backed-up ACL from the lock phase.

## 🎯 Common Usage

### Locking a Private Folder
```powershell
acllock lock "D:\Personal\PrivateData"
# You will be prompted for your ACL password
```

### Checking if something is Locked
```powershell
lock status "C:\Windows\System32" # (Just an example, don't lock System32!)
```

## 🛡️ Security Best Practices

### DO:
✅ **Run as Administrator** - ACL operations require elevated privileges.  
✅ **Remember your password** - It's required for unlocking!  
✅ **Use for Privacy** - Great for hiding folders from other local users.  

### DON'T:
❌ **Don't lock System Folders** - You could break Windows.  
❌ **Don't delete the backup folder** - It contains the original permissions.  
❌ **Don't use as primary encryption** - This is a permission lock, not file encryption (use `cipher-enhance` for that).

## ❓ Troubleshooting

### Forgotten Password
If you are an Administrator, you can reset the password by deleting the hash file:
```powershell
Remove-Item "$env:LOCALAPPDATA\acllock\auth.hash" -Force
```

### Broken Permissions
If a path becomes inaccessible even to Admins:
```powershell
takeown /f "C:\Path" /r /d y
icacls "C:\Path" /reset /t
```

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)

Need help? [Open an issue](https://github.com/mini-page/TheSecretJuice/issues)
