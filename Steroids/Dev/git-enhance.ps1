# git-enhance.ps1
# Enhanced Git PowerShell wrapper for interactive operations and beautiful logs
# Part of TheSecretJuice by mini-page

if ($null -eq (Get-Command Show-JuiceHelp -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path $PSScriptRoot "Core\Juice-Helpers.ps1"
    if (Test-Path $helperPath) { . $helperPath }
}

# Settings file location
$gitSettingsFile = "$env:USERPROFILE\.git-settings.json"

# Load saved settings
function Load-GitSettings {
    if (Test-Path $gitSettingsFile) {
        try {
            return Get-Content $gitSettingsFile | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }
    return $null
}

# Save settings
function Save-GitSettings {
    param($settings)
    try {
        $settings | ConvertTo-Json | Out-File $gitSettingsFile -Force
        Write-Host "   OK. Settings saved!" -ForegroundColor Green
    }
    catch {
        Write-Host "   WARNING: Could not save settings" -ForegroundColor Yellow
    }
}

function g {
    param(
        [string]$cmd,
        [switch]$useDefaults
    )
    
    # --- Banner ---
    Write-Host "`n╔══════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       GIT Interactive        ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════╝`n" -ForegroundColor Magenta
    
    # Check if in a git repo
    if (-not (git rev-parse --is-inside-work-tree -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Not a git repository." -ForegroundColor Red
        return
    }

    # Load saved settings
    $settings = Load-GitSettings
    if (-not $settings) {
        $settings = @{
            autoPush = "Ask"
            defaultRemote = "origin"
        }
    }

    Write-Host "Select an action:" -ForegroundColor Cyan
    Write-Host "   1. 📊 Status & Interactive Stage" -ForegroundColor White
    Write-Host "   2. ✍️  Guided Commit (Conventional)" -ForegroundColor White
    Write-Host "   3. 🔀 Branch Switcher (FZF)" -ForegroundColor White
    Write-Host "   4. 📜 Beautiful Log Graph" -ForegroundColor White
    Write-Host "   5. 🚀 Sync (Pull & Push)" -ForegroundColor White
    Write-Host "   6. 🛠️  Configure Settings" -ForegroundColor White
    Write-Host "   q. Exit" -ForegroundColor Gray
    
    $choice = Read-Host "`n   Choice"
    
    switch ($choice) {
        "1" { Invoke-GitSmartStatus }
        "2" { Invoke-GitGuidedCommit -settings $settings }
        "3" { Invoke-GitBranchSwitcher }
        "4" { git log --graph --oneline --decorate --all --color=always | fzf --ansi --header "Git Log (Press q to exit fzf)" }
        "5" { Invoke-GitSync -settings $settings }
        "6" { 
            Write-Host "1. Auto-Push: $( $settings.autoPush )"
            $pushChoice = Read-Host "   Set Auto-Push to: (1) Ask, (2) Always, (3) Never"
            switch ($pushChoice) {
                "1" { $settings.autoPush = "Ask" }
                "2" { $settings.autoPush = "Always" }
                "3" { $settings.autoPush = "Never" }
            }
            Save-GitSettings -settings $settings
        }
        "q" { return }
        default { git $args }
    }
}

function Invoke-GitSmartStatus {
    Write-Host "--- Git Status ---" -ForegroundColor Cyan
    git status -sb
    
    $unstaged = git diff --name-only
    if (-not $unstaged) {
        Write-Host "`nNo unstaged changes." -ForegroundColor Gray
    } else {
        $stageChoice = Read-Host "`n   Stage all changes? (y/n/i for interactive)"
        if ($stageChoice -eq 'y') {
            git add .
            Write-Host "   Staged everything." -ForegroundColor Green
        } elseif ($stageChoice -eq 'i' -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
            $files = git diff --name-only | fzf -m --header "Select files to STAGE (Tab to multi-select, Enter to confirm)"
            if ($files) {
                $files | ForEach-Object { git add $_ }
                Write-Host "   Staged selected files." -ForegroundColor Green
            }
        }
    }
}

function Invoke-GitGuidedCommit {
    param($settings)
    
    $staged = git diff --cached --name-only
    if (-not $staged) {
        Write-Host "ERROR: No staged changes to commit!" -ForegroundColor Red
        return
    }

    Write-Host "Commit Type:" -ForegroundColor Cyan
    Write-Host "   1. feat     (New feature)" -ForegroundColor White
    Write-Host "   2. fix      (Bug fix)" -ForegroundColor White
    Write-Host "   3. docs     (Documentation)" -ForegroundColor White
    Write-Host "   4. style    (Formatting, missing semi-colons, etc)" -ForegroundColor White
    Write-Host "   5. refactor (Code change that neither fixes a bug nor adds a feature)" -ForegroundColor White
    Write-Host "   6. chore    (Updating tasks, etc; no production code change)" -ForegroundColor White
    
    $typeChoice = Read-Host "   Choice (1-6)"
    $type = switch ($typeChoice) {
        "1" { "feat" }
        "2" { "fix" }
        "3" { "docs" }
        "4" { "style" }
        "5" { "refactor" }
        default { "chore" }
    }

    $scope = Read-Host "   Scope (optional, e.g. ui, parser)"
    $msg = Read-Host "   Message (required)"

    if (-not $msg) {
        Write-Host "Abort: Message required." -ForegroundColor Red
        return
    }

    $fullMsg = if ($scope) { "$type($scope): $msg" } else { "$type: $msg" }
    
    Write-Host "`nCommit message: " -NoNewline
    Write-Host "$fullMsg" -ForegroundColor Yellow
    $confirm = Read-Host "   Confirm commit? (Y/n)"
    
    if ($confirm -ne 'n') {
        git commit -m "$fullMsg"
        Write-Host "✓ Committed successfully!" -ForegroundColor Green
        
        # Auto-push logic
        $doPush = $false
        if ($settings.autoPush -eq "Always") { $doPush = $true }
        elseif ($settings.autoPush -eq "Ask") {
            $pushPrompt = Read-Host "   Push changes now? (y/N)"
            if ($pushPrompt -eq 'y') { $doPush = $true }
        }

        if ($doPush) {
            Invoke-GitSync -settings $settings
        }
    }
}

function Invoke-GitBranchSwitcher {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: fzf required for branch switcher." -ForegroundColor Red
        return
    }
    
    $branch = git branch --all --color=always | fzf --ansi --header "Select branch to SWITCH to"
    if ($branch) {
        $branch = $branch.Trim().Replace("* ", "")
        if ($branch -match "^remotes/") {
            $branch = $branch -replace "^remotes/[^/]+/", ""
        }
        git checkout $branch
    }
}

function Invoke-GitSync {
    param($settings)
    Write-Host "--- Syncing with $($settings.defaultRemote) ---" -ForegroundColor Cyan
    Write-Host "Pulling..." -ForegroundColor Gray
    git pull $settings.defaultRemote (git branch --show-current)
    Write-Host "Pushing..." -ForegroundColor Gray
    git push $settings.defaultRemote (git branch --show-current)
    Write-Host "✓ Sync complete!" -ForegroundColor Green
}

# Quick Aliases
function g-status { Invoke-GitSmartStatus }
function g-log { git log --graph --oneline --decorate --all }

function git-help {
    $cmds = @(
        @{ Cmd="g"; Desc="Interactive menu" },
        @{ Cmd="g-status"; Desc="Staging UI" },
        @{ Cmd="g-log"; Desc="Color graph" },
        @{ Cmd="Invoke-GitBranchSwitcher"; Desc="Fuzzy branches" },
        @{ Cmd="git-help"; Desc="Show this help menu" }
    )
    Show-JuiceHelp -Title "git-enhance Steroids" -Commands $cmds
}
Set-Alias -Name "git-help" -Value git-help

Write-Host "OK. git-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'git-help' for commands" -ForegroundColor Cyan
