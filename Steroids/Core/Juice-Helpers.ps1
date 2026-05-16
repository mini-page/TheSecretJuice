# Juice-Helpers.ps1
# Shared helper functions for TheSecretJuice ecosystem
# Part of TheSecretJuice by mini-page

function Write-Color {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Gray', 'DarkGray', 'Red', 'Green', 'Yellow', 'Cyan', 'Blue', 'Magenta', 'White')]
        [string]$Color = 'White',
        [switch]$NoNewLine
    )
    if ($NoNewLine) { 
        Write-Host -ForegroundColor $Color -NoNewline $Message 
    }
    else { 
        Write-Host -ForegroundColor $Color $Message 
    }
}

function Confirm-Action {
    param([string]$Message = "Proceed?", [switch]$AutoYes)
    if ($AutoYes) { return $true }
    $ans = Read-Host "$Message (Y/N)"
    return ($ans -match '^(?i)y(es)?$')
}

function Wait-Input {
    Read-Host "Press Enter to continue..." | Out-Null
}

function Write-JuiceBanner {
    param([string]$Title)
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    $paddedTitle = $Title.PadRight(28).Substring(0, 28)
    Write-Host "║ $paddedTitle ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
}

function Show-JuiceHelp {
    param(
        [string]$Title,
        [array]$Commands # Array of hashtables: @{ Cmd="..."; Desc="..." }
    )
    Write-JuiceBanner -Title $Title
    Write-Host "Available Commands:" -ForegroundColor Yellow
    foreach ($c in $Commands) {
        Write-Host "  • " -NoNewline -ForegroundColor Gray
        Write-Host ($c.Cmd.PadRight(15)) -ForegroundColor Green -NoNewline
        Write-Host " : " -NoNewline -ForegroundColor White
        Write-Host $c.Desc -ForegroundColor Gray
    }
    Write-Host ""
}
