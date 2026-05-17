# acllock-enhance.ps1
# Interactive ACL Lock Manager for files and folders
# Part of TheSecretJuice by mini-page

# ============================================================================
# ADMIN CHECK
# ============================================================================
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "❌ Error: Administrator privileges required for ACL operations." -ForegroundColor Red
    return
}

# ============================================================================
# GLOBALS & SETTINGS
# ============================================================================
$acllockBaseDir   = "$env:LOCALAPPDATA\acllock"
$acllockBackupDir = "$acllockBaseDir\backup"
$acllockAuthFile  = "$acllockBaseDir\auth.hash"

if (-not (Test-Path $acllockBackupDir)) {
    New-Item $acllockBackupDir -ItemType Directory -Force | Out-Null
}

# ============================================================================
# PASSWORD MANAGEMENT (v3.0 Hardened Vault)
# ============================================================================
function Ensure-AclPassword {
    $existing = Get-JuiceSecret -Target "AclLock"
    if ($null -eq $existing) {
        Write-JuiceBanner -Title "Setup ACL Password"
        Write-Host "  Password is required for lock/unlock operations." -ForegroundColor Cyan
        Write-Host "  (Securely stored in Windows Credential Manager)" -ForegroundColor Gray
        
        $p1 = Read-Host "  New password" -AsSecureString
        $p2 = Read-Host "  Confirm password" -AsSecureString

        # Use hardened Vault interface (passes SecureString directly)
        $ptr1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1)
        $ptr2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2)
        $plain1 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr1)
        $plain2 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr2)

        try {
            if ($plain1 -ne $plain2) {
                Write-Host "  ❌ Passwords do not match!" -ForegroundColor Red
                return $false
            }

            Set-JuiceSecret -Target "AclLock" -Secret $p1
            Write-Host "  ✅ Password secured in OS Vault!`n" -ForegroundColor Green
        } finally {
            # Zero out local plain text copies immediately
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr1)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr2)
        }
    }
    return $true
}

function Verify-AclPassword {
    $stored = Get-JuiceSecret -Target "AclLock"
    if ($null -eq $stored) {
        if (-not (Ensure-AclPassword)) { return $false }
        $stored = Get-JuiceSecret -Target "AclLock"
    }
    
    $input  = Read-Host "  Enter Password" -AsSecureString
    $ptr    = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($input)
    $plain  = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

    try {
        if ($plain -ne $stored) {
            Write-Host "  ❌ Invalid password!" -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            return $false
        }
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
    return $true
}

# ============================================================================
# CORE ACL OPERATIONS
# ============================================================================
function Backup-PathACL {
    param($Path)
    $id = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Path)) -replace '[^a-zA-Z0-9]', ''
    icacls $Path > "$acllockBackupDir\$id.acl"
}

function Restore-PathACL {
    param($Path)
    $id = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Path)) -replace '[^a-zA-Z0-9]', ''
    $file = "$acllockBackupDir\$id.acl"
    if (Test-Path $file) {
        icacls $Path /restore $file | Out-Null
    }
}

function Invoke-Lock {
    param($Path)
    Write-Host "  🔒 Locking: $Path..." -ForegroundColor Yellow
    Backup-PathACL $Path
    icacls $Path /inheritance:r | Out-Null
    icacls $Path /grant "Administrators:(OI)(CI)(F)" | Out-Null
    icacls $Path /deny  "Everyone:(OI)(CI)(F)" | Out-Null
    Write-Host "  ✅ Successfully Locked!" -ForegroundColor Green
}

function Invoke-Unlock {
    param($Path)
    Write-Host "  🔓 Unlocking: $Path..." -ForegroundColor Yellow
    icacls $Path /remove:d Everyone | Out-Null
    icacls $Path /inheritance:e | Out-Null
    Restore-PathACL $Path
    Write-Host "  ✅ Successfully Unlocked!" -ForegroundColor Green
}

function Get-PathLockStatus {
    param($Path)
    if ((icacls $Path) -match "DENY.*Everyone") {
        return "LOCKED"
    }
    return "UNLOCKED"
}

# ============================================================================
# MAIN INTERACTIVE FUNCTION
# ============================================================================

function acllock {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )

    # CLI Mode
    if ($args.Count -ge 2) {
        $cmd = $args[0]
        $path = $args[1]

        if (-not (Test-Path $path)) {
            Write-Host "❌ Invalid path: $path" -ForegroundColor Red
            return
        }

        switch ($cmd) {
            "lock" {
                if (Verify-AclPassword) { Invoke-Lock $path }
            }
            "unlock" {
                if (Verify-AclPassword) { Invoke-Unlock $path }
            }
            "status" {
                $status = Get-PathLockStatus $path
                $color = if ($status -eq "LOCKED") { "Red" } else { "Green" }
                Write-Host "Status: " -NoNewline
                Write-Host $status -ForegroundColor $color
            }
            default { acl-help }
        }
        return
    }

    # Interactive TUI Mode
    while ($true) {
        $Title = "ACL Lock Manager"
        Write-JuiceBanner -Title $Title
        
        Write-Host "  1. " -NoNewline -ForegroundColor Gray
        Write-Host "🔒 Lock File / Folder" -ForegroundColor Cyan
        Write-Host "  2. " -NoNewline -ForegroundColor Gray
        Write-Host "🔓 Unlock File / Folder" -ForegroundColor Cyan
        Write-Host "  3. " -NoNewline -ForegroundColor Gray
        Write-Host "📊 Check Status" -ForegroundColor Cyan
        Write-Host "  4. " -NoNewline -ForegroundColor Gray
        Write-Host "❓ Help" -ForegroundColor Cyan
        Write-Host "  5. " -NoNewline -ForegroundColor Gray
        Write-Host "🚪 Exit" -ForegroundColor Cyan
        
        Write-Host "`n  Choice: " -NoNewline -ForegroundColor Magenta
        $choice = Read-Host
        
        if ($choice -eq "5" -or $choice -eq "q") { break }
        if ($choice -eq "4" -or $choice -eq "h") { acl-help; Wait-Input; continue }

        $path = Read-Host "`n  Enter full path"
        if (-not (Test-Path $path)) {
            Write-Host "  ❌ Invalid path!" -ForegroundColor Red
            Start-Sleep -Seconds 1
            continue
        }

        switch ($choice) {
            "1" {
                if (Verify-AclPassword) { Invoke-Lock $path }
            }
            "2" {
                if (Verify-AclPassword) { Invoke-Unlock $path }
            }
            "3" {
                $status = Get-PathLockStatus $path
                $color = if ($status -eq "LOCKED") { "Red" } else { "Green" }
                Write-Host "`n  Current Status: " -NoNewline
                Write-Host $status -ForegroundColor $color
            }
        }
        
        Write-Host "`n"
        Wait-Input
    }
}

function acl-help {
    Show-JuiceHelp -Title "ACL Lock Manager" -Commands @(
        @{ Cmd="acllock"; Desc="Launch interactive lock manager" },
        @{ Cmd="acllock lock <path>"; Desc="Quickly lock a path" },
        @{ Cmd="acllock unlock <path>"; Desc="Quickly unlock a path" },
        @{ Cmd="acllock status <path>"; Desc="Check if a path is locked" },
        @{ Cmd="acl-help"; Desc="Show this help menu" }
    )
    Write-Host "  ADMIN: Use 'del (acllock status)' to reset password if forgotten." -ForegroundColor Gray
}

# ============================================================================
# ALIASES
# ============================================================================
Set-Alias -Name "acl" -Value "acllock"
Set-Alias -Name "lock" -Value "acllock"
