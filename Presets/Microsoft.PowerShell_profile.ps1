# ============================================
# The Secret Juice - Master Profile (v3.1)
# Optimized for Ultra-Fast Boot (< 1s)
# ============================================

$__ProfileStart = Get-Date

if ($env:PWSH_MINIMAL -eq "1") { return }

# 1. Boot Path Resolution
$JuiceRoot = "$HOME\Documents\PowerShell\Scripts\TheSecretJuice"
if (-not (Test-Path $JuiceRoot)) { $JuiceRoot = Split-Path $PSScriptRoot -Parent }

# 2. Load Core Only (Logic deferral)
$Core = Join-Path $JuiceRoot "Steroids\Core\Juice-Core.ps1"
if (Test-Path $Core) { . $Core }

# 3. Essential UI Only
$Theme = Join-Path $JuiceRoot "Presets\highContext.omp.json"
if (Test-Path $Theme) {
    try { oh-my-posh init pwsh --config $Theme | Invoke-Expression } catch { }
}

try { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } catch { }

# 4. Standard Modules (Non-blocking)
$modules = @('posh-git', 'PSFzf', 'PSReadLine')
foreach ($m in $modules) { 
    if (Get-Module $m -ListAvailable) { Import-Module $m -ErrorAction SilentlyContinue | Out-Null }
}

# 🏁 BOOT COMPLETE
$elapsed = [math]::Round(((Get-Date) - $__ProfileStart).TotalMilliseconds)
Write-Host "⚡ Juice v3.1 injected in ${elapsed}ms" -ForegroundColor DarkGray
