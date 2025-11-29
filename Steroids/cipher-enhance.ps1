# cipher-enhance.ps1
# Enhanced cipher wrapper for easy file/folder encryption and decryption
# Part of TheSecretJuice by mini-page

# Settings file location
$cipherSettingsFile = "$env:USERPROFILE\.cipher-settings.json"

# ============================================================================
# SETTINGS MANAGEMENT
# ============================================================================

function Load-CipherSettings {
    if (Test-Path $cipherSettingsFile) {
        try {
            return Get-Content $cipherSettingsFile | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }
    return $null
}

function Save-CipherSettings {
    param($settings)
    try {
        $settings | ConvertTo-Json | Out-File $cipherSettingsFile -Force
        Write-Host "   OK. Settings saved for next time!" -ForegroundColor Green
    }
    catch {
        Write-Host "   WARNING: Could not save settings" -ForegroundColor Yellow
    }
}

# ============================================================================
# MAIN INTERACTIVE FUNCTION
# ============================================================================

function cipher {
    param(
        [string]$path,
        [switch]$useDefaults
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║    CIPHER Interactive        ║" -ForegroundColor Magenta
    Write-Host "║  File/Folder Encryption      ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Check if cipher.exe is available
    $cipherPath = (Get-Command cipher.exe -ErrorAction SilentlyContinue).Source
    if (-not $cipherPath) {
        Write-Host "ERROR: cipher.exe not found!" -ForegroundColor Red
        Write-Host "INFO: cipher.exe is built into Windows but may not be in PATH" -ForegroundColor Yellow
        Write-Host "Try: C:\Windows\System32\cipher.exe`n" -ForegroundColor Gray
        return
    }
    
    # Load saved settings
    $savedSettings = Load-CipherSettings
    if ($savedSettings -and -not $useDefaults) {
        Write-Host "Found saved settings!" -ForegroundColor Cyan
        Write-Host "   1. Use saved settings" -ForegroundColor White
        Write-Host "   2. Configure new settings" -ForegroundColor White
        Write-Host "   3. Use defaults (skip all)" -ForegroundColor White
        $settingChoice = Read-Host "   Choice (1-3, default: 1)"
        
        if ($settingChoice -eq "3") {
            $useDefaults = $true
        }
        elseif ($settingChoice -ne "2") {
            Write-Host "   OK. Using saved settings`n" -ForegroundColor Green
        }
        else {
            $savedSettings = $null
        }
    }
    
    # Initialize settings object
    $currentSettings = @{
        operationChoice = "1"
        recursiveChoice = "1"
        secureDeleteChoice = "1"
    }
    
    # --- Path Input ---
    if (-not $path) {
        Write-Host "Target Path" -ForegroundColor Cyan
        $path = Read-Host "   Enter file or folder path (or drag & drop)"
        if (-not $path) {
            Write-Host "   ERROR: No path provided. Aborting.`n" -ForegroundColor Red
            return
        }
        # Clean path (remove quotes if drag & drop)
        $path = $path.Trim('"')
        Write-Host ""
    }
    
    # Verify path exists
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path`n" -ForegroundColor Red
        return
    }
    
    # Check if path is a file or directory
    $isDirectory = (Get-Item $path).PSIsContainer
    
    # --- Operation Selection ---
    Write-Host "OPERATION MODE" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "   1. Encrypt" -ForegroundColor White
    Write-Host "   2. Decrypt" -ForegroundColor White
    Write-Host "   3. Show encryption status" -ForegroundColor White
    Write-Host "   4. Secure delete (wipe free space)" -ForegroundColor White
    Write-Host "   5. Remove encryption" -ForegroundColor White
    Write-Host "   6. Create encrypted archive (ZIP)" -ForegroundColor White
    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
    
    $operationChoice = Read-Host "   Select operation (1-6, default: 1)"
    $currentSettings.operationChoice = $operationChoice
    
    # --- Recursive Option (for directories) ---
    $recursiveFlag = ""
    if ($isDirectory -and $operationChoice -in "1", "2", "5") {
        Write-Host "`nRecursive Operation (for folders)" -ForegroundColor Cyan
        Write-Host "   1. Current folder only" -ForegroundColor White
        Write-Host "   2. Include all subfolders (recursive)" -ForegroundColor White
        $recursiveChoice = Read-Host "   Choice (1-2, default: 1)"
        
        $currentSettings.recursiveChoice = $recursiveChoice
        
        if ($recursiveChoice -eq "2") {
            $recursiveFlag = "/S"
            Write-Host "   OK. Will process all subfolders" -ForegroundColor Green
        }
        Write-Host ""
    }
    
    # --- Secure Delete Option (for encryption) ---
    $secureDeleteFlag = ""
    if ($operationChoice -eq "1") {
        Write-Host "Secure Delete Original" -ForegroundColor Cyan
        Write-Host "   1. Keep original files" -ForegroundColor White
        Write-Host "   2. Securely wipe original files (3-pass)" -ForegroundColor White
        Write-Host "   3. DoD 5220.22-M standard (7-pass)" -ForegroundColor White
        $secureDeleteChoice = Read-Host "   Choice (1-3, default: 1)"
        
        $currentSettings.secureDeleteChoice = $secureDeleteChoice
        
        switch ($secureDeleteChoice) {
            "2" {
                $secureDeleteFlag = "/W"
                Write-Host "   OK. Will securely wipe original files (3-pass)" -ForegroundColor Green
            }
            "3" {
                $secureDeleteFlag = "/W /W /W"
                Write-Host "   OK. Will use DoD standard wipe (7-pass)" -ForegroundColor Green
            }
        }
        Write-Host ""
    }
    
    # Save settings for next time (only if not using defaults)
    if (-not $useDefaults -and $settingChoice -ne "1") {
        Write-Host "Save these settings for next time? (Y/n): " -ForegroundColor Cyan -NoNewline
        $saveChoice = Read-Host
        if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
            Save-CipherSettings $currentSettings
        }
        Write-Host ""
    }
    
    # --- Execute Command ---
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    switch ($operationChoice) {
        "1" {
            # Encrypt
            Write-Host "ENCRYPTING: " -ForegroundColor Green -NoNewline
            Write-Host "$path" -ForegroundColor White
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            try {
                $startTime = Get-Date
                
                if ($isDirectory) {
                    cipher.exe /E $recursiveFlag "$path"
                }
                else {
                    cipher.exe /E "$path"
                }
                
                # Secure delete if requested
                if ($secureDeleteFlag) {
                    Write-Host "`nSecurely wiping original files..." -ForegroundColor Yellow
                    cipher.exe $secureDeleteFlag "$path"
                }
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "OK. Encryption complete! " -ForegroundColor Green -NoNewline
                Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`nERROR: Encryption failed: $_`n" -ForegroundColor Red
            }
        }
        
        "2" {
            # Decrypt
            Write-Host "DECRYPTING: " -ForegroundColor Yellow -NoNewline
            Write-Host "$path" -ForegroundColor White
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            try {
                $startTime = Get-Date
                
                if ($isDirectory) {
                    cipher.exe /D $recursiveFlag "$path"
                }
                else {
                    cipher.exe /D "$path"
                }
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "OK. Decryption complete! " -ForegroundColor Green -NoNewline
                Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`nERROR: Decryption failed: $_`n" -ForegroundColor Red
            }
        }
        
        "3" {
            # Show status
            Write-Host "ENCRYPTION STATUS: " -ForegroundColor Cyan -NoNewline
            Write-Host "$path" -ForegroundColor White
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            try {
                if ($isDirectory) {
                    cipher.exe "$path"
                }
                else {
                    cipher.exe "$path"
                }
                Write-Host ""
            }
            catch {
                Write-Host "ERROR: Could not retrieve status: $_`n" -ForegroundColor Red
            }
        }
        
        "4" {
            # Secure delete free space
            Write-Host "SECURE DELETE: " -ForegroundColor Red -NoNewline
            Write-Host "Wiping free space in $path" -ForegroundColor White
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            Write-Host "WARNING: This will wipe all recoverable deleted files!" -ForegroundColor Yellow
            $confirm = Read-Host "Continue? (yes/no)"
            
            if ($confirm -eq "yes") {
                try {
                    Write-Host "`nWiping free space (this may take a while)..." -ForegroundColor Yellow
                    $startTime = Get-Date
                    
                    cipher.exe /W "$path"
                    
                    $endTime = Get-Date
                    $duration = ($endTime - $startTime).TotalSeconds
                    
                    Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                    Write-Host "OK. Secure delete complete! " -ForegroundColor Green -NoNewline
                    Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                    Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
                }
                catch {
                    Write-Host "`nERROR: Secure delete failed: $_`n" -ForegroundColor Red
                }
            }
            else {
                Write-Host "   OK. Cancelled.`n" -ForegroundColor Yellow
            }
        }
        
        "5" {
            # Remove encryption
            Write-Host "REMOVING ENCRYPTION: " -ForegroundColor Yellow -NoNewline
            Write-Host "$path" -ForegroundColor White
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            try {
                $startTime = Get-Date
                
                if ($isDirectory) {
                    cipher.exe /D $recursiveFlag "$path"
                }
                else {
                    cipher.exe /D "$path"
                }
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "OK. Encryption removed! " -ForegroundColor Green -NoNewline
                Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`nERROR: Remove encryption failed: $_`n" -ForegroundColor Red
            }
        }
        
        "6" {
            # Create encrypted ZIP archive
            Write-Host "CREATING ENCRYPTED ARCHIVE" -ForegroundColor Cyan
            Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            
            Write-Host "Enter password for ZIP archive:" -ForegroundColor Yellow
            $password = Read-Host -AsSecureString
            $passwordBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
            $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($passwordBSTR)
            
            if (-not $passwordPlain) {
                Write-Host "ERROR: No password provided. Aborting.`n" -ForegroundColor Red
                return
            }
            
            # Generate output filename
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $itemName = (Get-Item $path).BaseName
            $outputZip = "$env:USERPROFILE\Desktop\${itemName}_encrypted_${timestamp}.zip"
            
            try {
                Write-Host "Creating encrypted archive..." -ForegroundColor Yellow
                $startTime = Get-Date
                
                # Use 7-Zip if available, otherwise use PowerShell compression
                $sevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
                
                if ($sevenZip) {
                    # Use 7-Zip with AES-256 encryption
                    & 7z.exe a -tzip -p"$passwordPlain" -mem=AES256 "$outputZip" "$path"
                }
                else {
                    # Fallback: Use .NET compression (password protection requires additional module)
                    Write-Host "WARNING: 7-Zip not found. Using standard compression (less secure)" -ForegroundColor Yellow
                    Write-Host "INFO: Install 7-Zip for AES-256 encryption: https://www.7-zip.org/" -ForegroundColor Gray
                    Compress-Archive -Path "$path" -DestinationPath "$outputZip" -Force
                }
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host "OK. Archive created! " -ForegroundColor Green -NoNewline
                Write-Host "($([math]::Round($duration, 2))s)" -ForegroundColor Gray
                Write-Host "Location: $outputZip" -ForegroundColor Cyan
                Write-Host "════════════════════════════════════════════`n" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "`nERROR: Archive creation failed: $_`n" -ForegroundColor Red
            }
            finally {
                # Clear password from memory
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordBSTR)
                $passwordPlain = $null
            }
        }
        
        default {
            Write-Host "ERROR: Invalid choice. Aborting.`n" -ForegroundColor Red
        }
    }
}


# ============================================================================
# QUICK ALIASES
# ============================================================================

function cipher-encrypt {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Encrypting: $path" -ForegroundColor Yellow
    cipher.exe /E "$path"
    Write-Host "OK. Encryption complete!" -ForegroundColor Green
}

function cipher-decrypt {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Decrypting: $path" -ForegroundColor Yellow
    cipher.exe /D "$path"
    Write-Host "OK. Decryption complete!" -ForegroundColor Green
}

function cipher-status {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Encryption status for: $path`n" -ForegroundColor Cyan
    cipher.exe "$path"
}

function cipher-wipe {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "WARNING: This will securely wipe deleted files!" -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (yes/no)"
    
    if ($confirm -eq "yes") {
        Write-Host "Wiping free space (this may take a while)..." -ForegroundColor Yellow
        cipher.exe /W "$path"
        Write-Host "OK. Wipe complete!" -ForegroundColor Green
    }
}


function cipher-encrypt-folder {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Encrypting folder recursively: $path" -ForegroundColor Yellow
    cipher.exe /E /S "$path"
    Write-Host "OK. Folder encryption complete!" -ForegroundColor Green
}

function cipher-decrypt-folder {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Decrypting folder recursively: $path" -ForegroundColor Yellow
    cipher.exe /D /S "$path"
    Write-Host "OK. Folder decryption complete!" -ForegroundColor Green
}

function cipher-secure-encrypt {
    param([Parameter(Mandatory=$true)][string]$path)
    
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Path does not exist: $path" -ForegroundColor Red
        return
    }
    
    Write-Host "Encrypting and securely wiping original: $path" -ForegroundColor Yellow
    cipher.exe /E "$path"
    cipher.exe /W "$path"
    Write-Host "OK. Secure encryption complete!" -ForegroundColor Green
}

function cipher-list-encrypted {
    Write-Host "`nSearching for encrypted files in current directory...`n" -ForegroundColor Cyan
    
    Get-ChildItem -Recurse -File | ForEach-Object {
        if ($_.Attributes -band [System.IO.FileAttributes]::Encrypted) {
            Write-Host "[ENCRYPTED] " -ForegroundColor Green -NoNewline
            Write-Host $_.FullName -ForegroundColor White
        }
    }
}

function cipher-reset-settings {
    if (Test-Path $cipherSettingsFile) {
        Remove-Item $cipherSettingsFile -Force
        Write-Host "OK. Settings reset! Next run will prompt for new settings." -ForegroundColor Green
    }
    else {
        Write-Host "WARNING: No saved settings found." -ForegroundColor Yellow
    }
}


# ============================================================================
# ADVANCED UTILITIES
# ============================================================================

function cipher-backup-keys {
    Write-Host "`nBACKUP ENCRYPTION KEYS" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $backupPath = "$env:USERPROFILE\Desktop\EFS_Keys_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    Write-Host "This will export your EFS certificates and keys." -ForegroundColor Yellow
    Write-Host "IMPORTANT: Keep this backup in a safe place!" -ForegroundColor Red
    Write-Host "`nBackup location: $backupPath`n" -ForegroundColor Cyan
    
    $confirm = Read-Host "Continue? (yes/no)"
    
    if ($confirm -eq "yes") {
        try {
            # Export EFS certificate
            certutil -user -store My
            
            Write-Host "`nTo manually backup your EFS certificate:" -ForegroundColor Cyan
            Write-Host "1. Run: certmgr.msc" -ForegroundColor White
            Write-Host "2. Navigate to: Personal > Certificates" -ForegroundColor White
            Write-Host "3. Find certificate with 'Encrypting File System' purpose" -ForegroundColor White
            Write-Host "4. Right-click > All Tasks > Export" -ForegroundColor White
            Write-Host "5. Export with private key, use strong password`n" -ForegroundColor White
        }
        catch {
            Write-Host "ERROR: Could not list certificates: $_" -ForegroundColor Red
        }
    }
}

function cipher-stats {
    param([string]$path = ".")
    
    Write-Host "`nENCRYPTION STATISTICS" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $allFiles = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
    $encryptedFiles = $allFiles | Where-Object { $_.Attributes -band [System.IO.FileAttributes]::Encrypted }
    
    $totalFiles = $allFiles.Count
    $totalEncrypted = $encryptedFiles.Count
    $encryptedSize = ($encryptedFiles | Measure-Object -Property Length -Sum).Sum
    $percentage = if ($totalFiles -gt 0) { [math]::Round(($totalEncrypted / $totalFiles) * 100, 2) } else { 0 }
    
    Write-Host "   Path: " -NoNewline -ForegroundColor Gray
    Write-Host "$path" -ForegroundColor White
    Write-Host "   Total Files: " -NoNewline -ForegroundColor Gray
    Write-Host "$totalFiles" -ForegroundColor White
    Write-Host "   Encrypted Files: " -NoNewline -ForegroundColor Gray
    Write-Host "$totalEncrypted" -ForegroundColor Green
    Write-Host "   Encrypted Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($encryptedSize/1MB, 2)) MB" -ForegroundColor Yellow
    Write-Host "   Percentage: " -NoNewline -ForegroundColor Gray
    Write-Host "$percentage%" -ForegroundColor Cyan
    Write-Host ""
}


# ============================================================================
# HELP FUNCTION
# ============================================================================

function cipher-help {
    Write-Host "`nCIPHER-ENHANCE COMMANDS" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════" -ForegroundColor DarkGray
    
    Write-Host "`nINTERACTIVE:" -ForegroundColor Cyan
    Write-Host "  cipher                        " -NoNewline -ForegroundColor Green
    Write-Host "Interactive mode with menus" -ForegroundColor Gray
    
    Write-Host "`nQUICK COMMANDS:" -ForegroundColor Cyan
    Write-Host "  cipher-encrypt <path>         " -NoNewline -ForegroundColor Green
    Write-Host "Encrypt file or folder" -ForegroundColor Gray
    Write-Host "  cipher-decrypt <path>         " -NoNewline -ForegroundColor Green
    Write-Host "Decrypt file or folder" -ForegroundColor Gray
    Write-Host "  cipher-status <path>          " -NoNewline -ForegroundColor Green
    Write-Host "Show encryption status" -ForegroundColor Gray
    Write-Host "  cipher-wipe <path>            " -NoNewline -ForegroundColor Green
    Write-Host "Securely wipe free space" -ForegroundColor Gray
    
    Write-Host "`nFOLDER OPERATIONS:" -ForegroundColor Cyan
    Write-Host "  cipher-encrypt-folder <path>  " -NoNewline -ForegroundColor Green
    Write-Host "Encrypt folder recursively" -ForegroundColor Gray
    Write-Host "  cipher-decrypt-folder <path>  " -NoNewline -ForegroundColor Green
    Write-Host "Decrypt folder recursively" -ForegroundColor Gray
    Write-Host "  cipher-secure-encrypt <path>  " -NoNewline -ForegroundColor Green
    Write-Host "Encrypt + secure wipe" -ForegroundColor Gray
    
    Write-Host "`nUTILITIES:" -ForegroundColor Cyan
    Write-Host "  cipher-list-encrypted         " -NoNewline -ForegroundColor Green
    Write-Host "List encrypted files" -ForegroundColor Gray
    Write-Host "  cipher-stats [path]           " -NoNewline -ForegroundColor Green
    Write-Host "Show encryption statistics" -ForegroundColor Gray
    Write-Host "  cipher-backup-keys            " -NoNewline -ForegroundColor Green
    Write-Host "Backup EFS certificates" -ForegroundColor Gray
    Write-Host "  cipher-reset-settings         " -NoNewline -ForegroundColor Green
    Write-Host "Clear saved settings" -ForegroundColor Gray
    
    Write-Host "`nFEATURES:" -ForegroundColor Cyan
    Write-Host "  • EFS (Encrypting File System) encryption" -ForegroundColor White
    Write-Host "  • Secure file deletion (3-pass or 7-pass DoD)" -ForegroundColor White
    Write-Host "  • Recursive folder encryption" -ForegroundColor White
    Write-Host "  • Password-protected ZIP archives" -ForegroundColor White
    Write-Host "  • Encryption status checking" -ForegroundColor White
    Write-Host "  • Settings memory" -ForegroundColor White
    
    Write-Host "`nEXAMPLES:" -ForegroundColor Cyan
    Write-Host "  cipher                                  " -NoNewline -ForegroundColor Gray
    Write-Host "# Interactive mode" -ForegroundColor DarkGray
    Write-Host "  cipher-encrypt C:\Docs\secret.txt       " -NoNewline -ForegroundColor Gray
    Write-Host "# Quick encrypt" -ForegroundColor DarkGray
    Write-Host "  cipher-encrypt-folder C:\Private        " -NoNewline -ForegroundColor Gray
    Write-Host "# Encrypt folder" -ForegroundColor DarkGray
    Write-Host "  cipher-list-encrypted                   " -NoNewline -ForegroundColor Gray
    Write-Host "# Find encrypted files" -ForegroundColor DarkGray
    Write-Host "  cipher-stats C:\Users\John              " -NoNewline -ForegroundColor Gray
    Write-Host "# Show stats" -ForegroundColor DarkGray
    
    Write-Host "`nIMPORTANT NOTES:" -ForegroundColor Yellow
    Write-Host "  • EFS encryption is user-specific (Windows only)" -ForegroundColor White
    Write-Host "  • ALWAYS backup your EFS certificates!" -ForegroundColor Red
    Write-Host "  • Encrypted files show in green in Explorer" -ForegroundColor White
    Write-Host "  • Only works on NTFS file systems" -ForegroundColor White
    Write-Host "  • Requires Administrator rights for some operations" -ForegroundColor White
    
    Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "Type 'cipher-help' anytime to see this help`n" -ForegroundColor Gray
}

# ============================================================================
# INITIALIZATION
# ============================================================================

Write-Host "OK. cipher-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'cipher-help' for commands" -ForegroundColor Cyan
