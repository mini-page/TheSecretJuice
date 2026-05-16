# Help-Summary.ps1
# Part of TheSecretJuice - Core Pack
# The Master Help & Summary for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" }
    if (Test-Path $helperPath) { . $helperPath }
}

function juice-help {
    param([string]$tool)

    if ($tool) {
        $helpCmd = "$tool-help"
        if (Get-Command $helpCmd -ErrorAction SilentlyContinue) {
            Invoke-Expression $helpCmd
            return
        }
    }

    Write-JuiceBanner -Title "The Secret Juice Master Help"
    Write-Host "Welcome to the ultimate PowerShell steroid ecosystem! 💉✨" -ForegroundColor Cyan
    Write-Host "`nAvailable Steroid Packs:" -ForegroundColor Yellow

    $packs = @(
        @{ Pack="Media"; Cmd="yt-help"; Desc="yt-dlp enhancements for downloads" },
        @{ Pack="Navigation"; Cmd="nav-help"; Desc="zoxide + eza smart navigation" },
        @{ Pack="Files"; Cmd="robo-help"; Desc="Robocopy presets and scheduling" },
        @{ Pack="Search"; Cmd="fzf-help"; Desc="Fuzzy finding for files and procs" },
        @{ Pack="Dev"; Cmd="git-help"; Desc="Interactive Git & Conventional Commits" },
        @{ Pack="System"; Cmd="optimize"; Desc="Maintenance, cleanup, and specs" },
        @{ Pack="Apps"; Cmd="update-apps"; Desc="Update winget/scoop/choco apps" },
        @{ Pack="Network"; Cmd="net-works"; Desc="Connectivity and IP diagnostics" }
    )

    foreach ($p in $packs) {
        Write-Host "  • " -NoNewline -ForegroundColor Gray
        Write-Host ($p.Pack.PadRight(12)) -ForegroundColor Magenta -NoNewline
        Write-Host " -> Use: " -NoNewline -ForegroundColor Gray
        Write-Host ($p.Cmd.PadRight(12)) -ForegroundColor Green -NoNewline
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host $p.Desc -ForegroundColor Gray
    }

    Write-Host "`n💡 Pro Tip: Type 'juice-help <tool>' (e.g., 'juice-help git') for direct help." -ForegroundColor Yellow
    Write-Host "🚀 Project Home: https://github.com/mini-page/TheSecretJuice" -ForegroundColor Cyan
    Write-Host ""
}

# Override native help if user wants, but keep 'juice-help' as primary
Set-Alias -Name "juice-help" -Value juice-help
if (-not (Get-Command juice -ErrorAction SilentlyContinue)) {
    Set-Alias -Name "juice" -Value juice-help
}
