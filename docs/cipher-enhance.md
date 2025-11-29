# 🔐 cipher-enhance

Lightweight, fast, interactive PowerShell wrapper for Windows `cipher.exe` - Easy file and folder encryption/decryption using EFS (Encrypting File System).

**Script file:** `cipher-enhance.ps1`

## 🆕 What's New

- **🔒 Interactive Encryption/Decryption** - Beautiful menus for all operations
- **🗑️ Secure File Deletion** - 3-pass or DoD 7-pass wipe standards
- **📁 Recursive Folder Support** - Encrypt entire directory trees
- **📦 Encrypted ZIP Archives** - Create password-protected archives
- **📊 Encryption Statistics** - Track encrypted files and sizes
- **🔑 Key Backup Assistant** - Easy EFS certificate backup
- **💾 Settings Memory** - Save preferences for quick operations
- **⚡ Quick Aliases** - One-line commands for common tasks

## 🚀 Quick Start

```powershell
# Interactive mode (easiest)
cipher

# Quick file encryption
cipher-encrypt C:\Documents\secret.txt

# Quick file decryption
cipher-decrypt C:\Documents\secret.txt

# Encrypt entire folder
cipher-encrypt-folder C:\PrivateData

# Check encryption status
cipher-status C:\Documents

# Show help
cipher-help
```

## 📋 Menu Options

### Main Operations

| Option | Feature | What it does |
|--------|---------|--------------|
| 1 | **Encrypt** | Encrypts files/folders using EFS |
| 2 | **Decrypt** | Removes encryption from files/folders |
| 3 | **Show Status** | Displays encryption status |
| 4 | **Secure Delete** | Wipes free space (3-pass overwrite) |
| 5 | **Remove Encryption** | Decrypts and removes protection |
| 6 | **Create Encrypted Archive** | ZIP with password protection |

### Secure Delete Options

1. **Keep original files** - Standard encryption
2. **3-pass wipe** - Secure deletion (DOD 5220.22-M)
3. **7-pass wipe** - Maximum security (government standard)

### Recursive Options (for folders)

1. **Current folder only** - Don't process subfolders
2. **Include all subfolders** - Recursive operation

## 🔐 Understanding EFS Encryption

### What is EFS?

**EFS (Encrypting File System)** is a Windows feature that provides filesystem-level encryption:

- **Per-user encryption** - Only you can decrypt your files
- **Transparent** - Files are encrypted/decrypted automatically
- **NTFS only** - Requires NTFS file system
- **Hardware-backed** - Uses your Windows login credentials

### Why Use EFS?

✅ **Protects against:** Physical theft, unauthorized access, data recovery tools
✅ **Transparent:** Access files normally, encryption is automatic  
✅ **Fast:** Hardware-accelerated encryption  
✅ **Built-in:** No third-party software needed  
✅ **Free:** Included with Windows  

### Security Level

- **Algorithm:** AES-256 (or 3DES on older systems)
- **Key Length:** 256-bit  
- **Standards:** FIPS 140-2 compliant  
- **Certificate:** RSA 2048-bit  

## 🎯 Common Usage

### Encrypt a Sensitive File

```powershell
# Method 1: Interactive
cipher
# Select file, choose encrypt

# Method 2: Quick command
cipher-encrypt C:\Documents\passwords.txt
```

### Encrypt Entire Folder

```powershell
# Recursive encryption
cipher-encrypt-folder C:\PrivateDocuments

# Or interactive
cipher
# Select folder, choose recursive option
```

### Decrypt Files

```powershell
# Single file
cipher-decrypt C:\Documents\secret.txt

# Entire folder
cipher-decrypt-folder C:\PrivateDocuments
```

### Check What's Encrypted

```powershell
# List all encrypted files in current directory
cipher-list-encrypted

# Show statistics
cipher-stats C:\Users\YourName\Documents
```

### Secure Delete (Wipe Free Space)

```powershell
# Interactive
cipher
# Select option 4

# Quick command
cipher-wipe C:\
# WARNING: This wipes ALL recoverable deleted files!
```

### Create Encrypted ZIP Archive

```powershell
cipher
# Select option 6
# Enter password
# Archive saved to Desktop
```

**Requirements:**
- 7-Zip (recommended) - AES-256 encryption
- Built-in compression (fallback) - Standard ZIP

## 🔑 Backup Your Encryption Keys

**CRITICAL:** Always backup your EFS certificates!

### Why Backup?

- If you lose your certificate, **encrypted files are PERMANENTLY LOST**
- Windows reinstall = Lost certificate = Lost data
- Hardware failure = Lost certificate = Lost data

### How to Backup

```powershell
# Interactive backup assistant
cipher-backup-keys

# Manual backup (recommended):
1. Run: certmgr.msc
2. Navigate to: Personal > Certificates
3. Find: Certificate with "Encrypting File System"
4. Right-click > All Tasks > Export
5. Export WITH private key
6. Use STRONG password
7. Store backup SAFELY (external drive, cloud)
```

## 📊 Statistics & Monitoring

### View Encryption Stats

```powershell
# Current directory
cipher-stats

# Specific path
cipher-stats C:\Users\YourName

# Output example:
# Total Files: 1,542
# Encrypted Files: 387
# Encrypted Size: 2.34 GB
# Percentage: 25.10%
```

### List Encrypted Files

```powershell
cipher-list-encrypted

# Shows:
# [ENCRYPTED] C:\Docs\secret.txt
# [ENCRYPTED] C:\Docs\passwords.xlsx
# [ENCRYPTED] C:\Private\keys.pem
```

## ⚡ Quick Command Reference

### Basic Operations

```powershell
cipher-encrypt <path>          # Encrypt file/folder
cipher-decrypt <path>          # Decrypt file/folder
cipher-status <path>           # Show encryption status
cipher-wipe <path>             # Secure delete free space
```

### Folder Operations

```powershell
cipher-encrypt-folder <path>   # Encrypt folder + subfolders
cipher-decrypt-folder <path>   # Decrypt folder + subfolders
cipher-secure-encrypt <path>   # Encrypt + wipe original
```

### Utilities

```powershell
cipher-list-encrypted          # List encrypted files
cipher-stats [path]            # Show statistics
cipher-backup-keys             # Backup EFS certificates
cipher-reset-settings          # Clear saved settings
cipher-help                    # Show help
```

## 🛡️ Security Best Practices

### DO:
✅ **Backup your EFS certificate** - Store in multiple safe locations  
✅ **Use strong Windows password** - Your encryption depends on it  
✅ **Enable BitLocker** - For full-disk encryption layer  
✅ **Test decryption** - Verify you can decrypt before relying on it  
✅ **Keep Windows updated** - Security patches are important  

### DON'T:
❌ **Don't lose your certificate** - Encrypted data will be unrecoverable  
❌ **Don't share your Windows account** - Others can access encrypted files  
❌ **Don't encrypt system files** - Can cause boot issues  
❌ **Don't rely only on EFS** - Use multiple security layers  
❌ **Don't forget your password** - No password = No encryption keys  

## 📁 File System Requirements

### Supported

✅ **NTFS** - Full support (Windows NT File System)  
✅ **Local drives** - C:\, D:\, etc.  
✅ **External NTFS drives** - USB drives formatted as NTFS  

### Not Supported

❌ **FAT32** - No encryption support  
❌ **exFAT** - No encryption support  
❌ **Network drives** - Limited support  
❌ **Non-Windows systems** - EFS is Windows-only  

## ❓ Troubleshooting

### "Access Denied" Error

**Solution:**
```powershell
# Run PowerShell as Administrator
# Right-click > Run as Administrator
```

### "cipher.exe not found"

**Solution:**
```powershell
# cipher.exe is built into Windows
# Check: C:\Windows\System32\cipher.exe

# Add to PATH or use full path:
C:\Windows\System32\cipher.exe /E "C:\file.txt"
```

### "The file or directory is corrupted"

**Solution:**
- Run disk check: `chkdsk C: /F`
- Restore from backup
- File system may be damaged

### "Certificate not found"

**Solution:**
```powershell
# Generate new EFS certificate:
cipher /R

# Or encrypt a file to auto-generate:
cipher /E C:\test.txt
```

### Can't Decrypt Files After Windows Reinstall

**Solution:**
- **Import your backed-up certificate**
- If no backup: **Data is permanently lost**
- This is why backups are critical!

### Encrypted Files Show as Accessible to Others

**Explanation:**
- EFS is **user-specific**
- Other users **cannot** access encrypted files
- They see the file but get "Access Denied"
- Green color in Explorer = Encrypted

## 💡 Tips & Tricks

### Encrypt Sensitive Folders Automatically

```powershell
# Add to startup script
cipher-encrypt-folder "C:\Users\$env:USERNAME\Documents\Private"
```

### Quick Encrypt on Right-Click

1. Create PowerShell script: `encrypt.ps1`
2. Add to SendTo folder
3. Right-click > Send To > Encrypt

### Check if File is Encrypted (PowerShell)

```powershell
(Get-Item "C:\file.txt").Attributes -band [System.IO.FileAttributes]::Encrypted
```

### Bulk Encrypt Files by Extension

```powershell
Get-ChildItem -Recurse -Filter *.pdf | ForEach-Object {
    cipher-encrypt $_.FullName
}
```

### Monitor Encryption Status

```powershell
# Show daily stats
cipher-stats C:\Users\$env:USERNAME
```

## 🎨 Color Guide

- 🟢 **Green** = Success, Encrypted
- 🔴 **Red** = Error, Deletion
- 🔵 **Cyan** = Info, Headers
- 🟡 **Yellow** = Processing, Warnings
- ⚪ **Gray** = Details

## 📝 Examples

### Secure Document Storage

```powershell
# Create encrypted folder
New-Item -ItemType Directory -Path "C:\SecureDocs"
cipher-encrypt-folder "C:\SecureDocs"

# Verify
cipher-stats "C:\SecureDocs"
```

### Secure Delete Sensitive File

```powershell
# Encrypt first
cipher-encrypt "C:\sensitive.doc"

# Then secure wipe original
cipher-wipe "C:\sensitive.doc"
```

### Prepare for External Storage

```powershell
# Create encrypted ZIP
cipher
# Select option 6
# Choose files/folders
# Set strong password
# Copy ZIP to USB drive
```

### Audit Encryption Usage

```powershell
# Check all user directories
$users = Get-ChildItem C:\Users -Directory

foreach ($user in $users) {
    Write-Host "`nUser: $($user.Name)" -ForegroundColor Cyan
    cipher-stats $user.FullName
}
```

## 🚀 Performance

### Lightweight

- **No background processes** - Only runs when called
- **Direct cipher.exe calls** - Minimal overhead
- **Fast operations** - Hardware-accelerated encryption

### Speed Benchmarks (estimates)

- **Small file (1 MB):** < 1 second
- **Medium file (100 MB):** 2-5 seconds
- **Large file (1 GB):** 10-30 seconds
- **Folder (1000 files):** 30-60 seconds

*Speeds vary based on: CPU, disk speed, file count, file types*

## 🔗 Related Tools

- **BitLocker** - Full disk encryption
- **7-Zip** - Encrypted archives (install for option 6)
- **VeraCrypt** - Encrypted containers
- **GPG** - OpenPGP encryption

## 📚 Further Reading

- [Microsoft EFS Documentation](https://docs.microsoft.com/en-us/windows/security/information-protection/encrypted-file-system)
- [cipher.exe Command Reference](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cipher)
- [EFS Best Practices](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc784355(v=ws.10))

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)

Need help? [Open an issue](https://github.com/mini-page/TheSecretJuice/issues)
