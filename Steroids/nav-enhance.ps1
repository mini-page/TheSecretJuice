# nav-enhance.ps1
# Enhanced navigation with zoxide + eza integration
# Part of TheSecretJuice by mini-page

if ($null -eq (Get-Command Show-JuiceHelp -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path $PSScriptRoot "Core\Juice-Helpers.ps1"
    if (Test-Path $helperPath) { . $helperPath }
}

# ============================================================================
# ZOXIDE ENHANCED NAVIGATION
# ============================================================================

# Smart jump with listing (original enhanced)
function zz { 
    $target = zoxide query @Args
    if ($target) {
        Set-Location $target
        lb
    }
}

# Interactive fuzzy jump with fzf
function zi {
    $selection = zoxide query --list | fzf --height 40% --reverse --preview 'eza --icons --color=always -lh {}'
    if ($selection) {
        Set-Location $selection
        lb
    }
}

# Jump and open in VSCode
function zc {
    $target = zoxide query @Args
    if ($target) {
        Set-Location $target
        code .
    }
}

# Jump and open in explorer/finder
function ze {
    $target = zoxide query @Args
    if ($target) {
        if ($IsWindows -or $env:OS -match "Windows") {
            explorer $target
        } elseif ($IsMacOS) {
            open $target
        } else {
            xdg-open $target
        }
    }
}

# Quick numbered jumps (shows list with numbers, then jump)
function zn {
    $dirs = zoxide query --list | Select-Object -First 10
    $i = 1
    $dirs | ForEach-Object {
        Write-Host "$i. " -ForegroundColor Cyan -NoNewline
        Write-Host "$_" -ForegroundColor White
        $i++
    }
    $choice = Read-Host "`nJump to (1-10)"
    if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $dirs.Count) {
        Set-Location $dirs[$choice - 1]
        lb
    }
}

# Jump back in history
function z- { Set-Location -; lb }

# Add current directory to zoxide
function za { zoxide add (Get-Location).Path }

# ============================================================================
# EZA ENHANCED LISTINGS
# ============================================================================

# Basic listings (original + improved)
function lb { eza --icons --group-directories-first --color=always @Args }
function ll { eza --icons --group-directories-first --color=always -lh @Args }
function la { eza --icons --group-directories-first --color=always -lha @Args }
function lt { eza --icons --group-directories-first --color=always --tree --level=2 @Args }
function ld { eza --icons --group-directories-first --color=always -lha --git --extended --tree --level=3 --sort=ext --time-style=long-iso @Args }

# Sort by size (largest first)
function lz { eza --icons --group-directories-first --color=always -lha --sort=size --reverse @Args }

# Sort by modified time (newest first)
function lm { eza --icons --group-directories-first --color=always -lha --sort=modified --reverse @Args }

# Sort by created time
function lc { eza --icons --group-directories-first --color=always -lha --sort=created --reverse @Args }

# Only directories
function ldo { eza --icons --color=always -lhD @Args }

# Only files
function lf { eza --icons --color=always -lha | Select-String -NotMatch '^d' }

# Git-focused view (show git status prominently)
function lg { eza --icons --group-directories-first --color=always -lha --git --git-ignore @Args }

# Deep tree (4 levels)
function ltt { eza --icons --group-directories-first --color=always --tree --level=4 @Args }

# Full details with permissions
function lp { eza --icons --group-directories-first --color=always -lha --extended --octal-permissions @Args }

# Media files view (images, videos, audio)
function lmedia { 
    eza --icons --group-directories-first --color=always -lha |
    Select-String -Pattern '\.(jpg|jpeg|png|gif|bmp|svg|mp4|mkv|avi|mov|mp3|wav|flac)$'
}

# Code files view (common programming languages)
function lcode {
    eza --icons --group-directories-first --color=always -lha |
    Select-String -Pattern '\.(ps1|py|js|ts|jsx|tsx|java|c|cpp|cs|go|rs|rb|php|html|css|json|xml|yml|yaml|md)$'
}

# Documents view
function ldoc {
    eza --icons --group-directories-first --color=always -lha |
    Select-String -Pattern '\.(pdf|doc|docx|txt|md|xlsx|xls|ppt|pptx)$'
}

# Recent files (modified in last 24 hours)
function lr {
    eza --icons --group-directories-first --color=always -lha --sort=modified --reverse |
    Select-Object -First 20
}

# Large files (over 10MB)
function lbig {
    eza --icons --group-directories-first --color=always -lha --sort=size --reverse |
    Select-Object -First 20
}

# ============================================================================
# COMBINED POWER COMMANDS
# ============================================================================

# Jump with fzf, then choose action
function zx {
    $selection = zoxide query --list | fzf --height 40% --reverse --preview 'eza --icons --color=always -lh {}'
    if ($selection) {
        Write-Host "`nActions:" -ForegroundColor Cyan
        Write-Host "1. Navigate (cd)" -ForegroundColor White
        Write-Host "2. Open in VSCode" -ForegroundColor White
        Write-Host "3. Open in Explorer" -ForegroundColor White
        Write-Host "4. Show tree view" -ForegroundColor White
        Write-Host "5. Git status" -ForegroundColor White
        $action = Read-Host "`nChoice (1-5, Enter=1)"
        
        switch ($action) {
            "2" { code $selection }
            "3" { 
                if ($IsWindows -or $env:OS -match "Windows") { explorer $selection }
                elseif ($IsMacOS) { open $selection }
                else { xdg-open $selection }
            }
            "4" { eza --icons --tree --level=3 --color=always $selection }
            "5" { Set-Location $selection; git status }
            default { Set-Location $selection; lb }
        }
    }
}

# Quick project finder (looks for git repos or specific folders)
function pj {
    param([string]$searchPath = $HOME)
    
    Get-ChildItem -Path $searchPath -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName ".git") } |
    Select-Object -ExpandProperty FullName |
    fzf --height 40% --reverse --preview 'eza --icons --color=always -lh {}' |
    ForEach-Object { Set-Location $_; lb }
}

# Find and navigate (search by name, then jump)
function fn {
    param([string]$pattern)
    
    if (-not $pattern) {
        Write-Host "Usage: fn [search-pattern]" -ForegroundColor Yellow
        return
    }
    
    Get-ChildItem -Directory -Recurse -Filter "*$pattern*" -Depth 3 -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName |
    fzf --height 40% --reverse --preview 'eza --icons --color=always -lh {}' |
    ForEach-Object { Set-Location $_; lb }
}

# Quick parent navigation
function .. { Set-Location ..; lb }
function ... { Set-Location ..\..; lb }
function .... { Set-Location ..\..\..; lb }

# Navigate and git status
function cdg {
    param([string]$path)
    Set-Location $path
    git status
}

# List with ripgrep integration (search file contents)
function lgrep {
    param([string]$pattern)
    
    if (-not $pattern) {
        Write-Host "Usage: lgrep [search-pattern]" -ForegroundColor Yellow
        return
    }
    
    rg --files-with-matches $pattern | ForEach-Object {
        eza --icons --color=always -lh $_
    }
}

# ============================================================================
# BOOKMARKS SYSTEM
# ============================================================================

$bookmarksFile = "$env:USERPROFILE\.nav_bookmarks.json"

# Add bookmark
function bm-add {
    param([string]$name)
    
    if (-not $name) {
        $name = Split-Path -Leaf (Get-Location)
    }
    
    $bookmarks = @{}
    if (Test-Path $bookmarksFile) {
        $bookmarks = Get-Content $bookmarksFile | ConvertFrom-Json -AsHashtable
    }
    
    $bookmarks[$name] = (Get-Location).Path
    $bookmarks | ConvertTo-Json | Out-File $bookmarksFile
    Write-Host "OK. Bookmarked: " -ForegroundColor Green -NoNewline
    Write-Host "$name -> $($bookmarks[$name])" -ForegroundColor Cyan
}

# Jump to bookmark
function bm {
    param([string]$name)
    
    if (-not (Test-Path $bookmarksFile)) {
        Write-Host "No bookmarks yet. Use 'bm-add [name]' to create one." -ForegroundColor Yellow
        return
    }
    
    $bookmarks = Get-Content $bookmarksFile | ConvertFrom-Json -AsHashtable
    
    if (-not $name) {
        # Show all bookmarks with fzf
        $selected = $bookmarks.Keys | fzf --height 40% --reverse --preview "eza --icons --color=always -lh $($bookmarks[{}])"
        if ($selected) {
            Set-Location $bookmarks[$selected]
            lb
        }
    } elseif ($bookmarks.ContainsKey($name)) {
        Set-Location $bookmarks[$name]
        lb
    } else {
        Write-Host "Bookmark '$name' not found." -ForegroundColor Red
    }
}

# List bookmarks
function bm-list {
    if (-not (Test-Path $bookmarksFile)) {
        Write-Host "No bookmarks yet." -ForegroundColor Yellow
        return
    }
    
    $bookmarks = Get-Content $bookmarksFile | ConvertFrom-Json -AsHashtable
    Write-Host "`nBookmarks:" -ForegroundColor Cyan
    $bookmarks.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key) " -ForegroundColor Green -NoNewline
        Write-Host "-> $($_.Value)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Remove bookmark
function bm-rm {
    param([string]$name)
    
    if (-not (Test-Path $bookmarksFile)) {
        Write-Host "No bookmarks to remove." -ForegroundColor Yellow
        return
    }
    
    $bookmarks = Get-Content $bookmarksFile | ConvertFrom-Json -AsHashtable
    
    if ($bookmarks.ContainsKey($name)) {
        $bookmarks.Remove($name)
        $bookmarks | ConvertTo-Json | Out-File $bookmarksFile
        Write-Host "OK. Removed bookmark: $name" -ForegroundColor Green
    } else {
        Write-Host "Bookmark '$name' not found." -ForegroundColor Red
    }
}

# ============================================================================
# QUICK STATS
# ============================================================================

# Show directory stats
function lst {
    $path = Get-Location
    $files = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue
    $dirs = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue
    $size = ($files | Measure-Object -Property Length -Sum).Sum
    
    Write-Host "`nDirectory Stats:" -ForegroundColor Cyan
    Write-Host "  Path: " -NoNewline -ForegroundColor Gray
    Write-Host "$path" -ForegroundColor White
    Write-Host "  Files: " -NoNewline -ForegroundColor Gray
    Write-Host "$($files.Count)" -ForegroundColor Green
    Write-Host "  Directories: " -NoNewline -ForegroundColor Gray
    Write-Host "$($dirs.Count)" -ForegroundColor Green
    Write-Host "  Total Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($size/1MB, 2)) MB" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# HELP
# ============================================================================

function nav-help {
    $cmds = @(
        @{ Cmd="zz"; Desc="Jump to dir" },
        @{ Cmd="zi"; Desc="Fuzzy jump" },
        @{ Cmd="ll"; Desc="Rich list" },
        @{ Cmd="la"; Desc="Show all" },
        @{ Cmd="bm-add"; Desc="Add bookmark" },
        @{ Cmd="bm"; Desc="Jump to bookmark" },
        @{ Cmd="nav-help"; Desc="Show this help menu" }
    )
    Show-JuiceHelp -Title "nav-enhance Steroids" -Commands $cmds
}
Set-Alias -Name "nav-help" -Value nav-help

# Show welcome message on load
Write-Host "OK. nav-enhance loaded! " -ForegroundColor Green -NoNewline
Write-Host "Type 'nav-help' for commands" -ForegroundColor Cyan
