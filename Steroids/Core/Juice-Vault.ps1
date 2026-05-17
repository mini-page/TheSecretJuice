# Juice-Vault.ps1
# Optimized OS Vault Integration for TheSecretJuice v3.0
# Defer-load architecture: Compiles only on first use.

function Initialize-JuiceVault {
    if (-not ([System.Management.Automation.PSTypeName]"WinVault").Type) {
        Write-Host "🔐 Initializing Secure Enclave..." -ForegroundColor Gray
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class WinVault {
    [DllImport("Advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredWriteW(ref CREDENTIAL credential, uint flags);

    [DllImport("Advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredReadW(string target, uint type, uint reserved, out IntPtr credentialPtr);

    [DllImport("Advapi32.dll", SetLastError = true)]
    public static extern void CredFree(IntPtr buffer);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public uint Flags;
        public uint Type;
        public string TargetName;
        public string Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public uint CredentialBlobSize;
        public IntPtr CredentialBlob;
        public uint Persist;
        public uint AttributeCount;
        public IntPtr Attributes;
        public string TargetAlias;
        public string UserName;
    }
}
'@
    }
}

function Set-JuiceVaultSecret {
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][SecureString]$SecureSecret
    )
    
    Initialize-JuiceVault
    
    $cred = New-Object WinVault+CREDENTIAL
    $cred.Type = 1 
    $cred.TargetName = "TheSecretJuice:$Target"
    $cred.Persist = 2 
    $cred.UserName = $env:USERNAME
    
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureSecret)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        $bytes = [Text.Encoding]::Unicode.GetBytes($plain)
        
        $cred.CredentialBlobSize = $bytes.Length
        $cred.CredentialBlob = [Marshal]::AllocCoTaskMem($bytes.Length)
        [Marshal]::Copy($bytes, 0, $cred.CredentialBlob, $bytes.Length)
        
        return [WinVault]::CredWriteW([ref]$cred, 0)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        if ($cred.CredentialBlob) { [Marshal]::FreeCoTaskMem($cred.CredentialBlob) }
    }
}

function Get-JuiceVaultSecret {
    param([string]$Target)
    
    Initialize-JuiceVault
    
    $ptr = [IntPtr]::Zero
    $res = [WinVault]::CredReadW("TheSecretJuice:$Target", 1, 0, [ref]$ptr)
    
    if ($res) {
        try {
            $cred = [Marshal]::PtrToStructure($ptr, [WinVault+CREDENTIAL])
            $bytes = New-Object byte[] $cred.CredentialBlobSize
            [Marshal]::Copy($cred.CredentialBlob, $bytes, 0, $bytes.Length)
            $secret = [Text.Encoding]::Unicode.GetString($bytes)
            return $secret
        } finally {
            [WinVault]::CredFree($ptr)
        }
    }
    return $null
}
