# install.ps1
# TheSecretJuice One-Line Installer
# Usage: iwr https://raw.githubusercontent.com/mini-page/TheSecretJuice/main/install.ps1 | iex

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║     TheSecretJuice Installer v1.0       ║" -ForegroundColor Magenta
Write-Host "║   PowerShell Steroids for CLI Tools     ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Magenta

# Detect OS and set paths
$isWindows = $IsWindows -or $env:OS -match "Windows"
if ($isWindows) {
    $scriptsPath = "$env:USERPROFILE\Documents\PowerShell\Scripts\TheSecretJuice\Steroids"
    $profilePath = $PROFILE
} else {
    $scriptsPath = "$HOME/.config/powershell/Scripts/TheSecretJuice/Steroids"
    $profilePath = "$HOME/.config/powershell/profile.ps1"
}

Write-Host "📦 Installing to: " -ForegroundColor Cyan -NoNewline
Write-Host "$scriptsPath`n" -ForegroundColor Yellow

# Create directory if it doesn't exist
try {
    if (-not (Test-Path $scriptsPath)) {
        New-Item -ItemType Directory -Path $scriptsPath -Force | Out-Null
        Write-Host "✓ Created directory" -ForegroundColor Green
    } else {
        Write-Host "✓ Directory exists" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Failed to create directory: $_" -ForegroundColor Red
    exit 1
}

# Download the repository
Write-Host "`n📥 Downloading TheSecretJuice..." -ForegroundColor Cyan

$zipUrl = "https://github.com/mini-page/TheSecretJuice/archive/refs/heads/main.zip"
$zipPath = Join-Path $env:TEMP "TheSecretJuice.zip"
$extractPath = Join-Path $env:TEMP "TheSecretJuice-extract"

try {
    # Download
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "✓ Downloaded repository" -ForegroundColor Green
    
    # Extract
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Write-Host "✓ Extracted files" -ForegroundColor Green
    
    # Copy files (GitHub adds -main to folder name)
    $sourceFolder = Join-Path $extractPath "TheSecretJuice-main"
    Copy-Item -Path "$sourceFolder\*" -Destination $scriptsPath -Recurse -Force
    Write-Host "✓ Copied to scripts folder" -ForegroundColor Green
    
    # Cleanup
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Host "❌ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Check/create PowerShell profile
Write-Host "`n📝 Configuring PowerShell profile..." -ForegroundColor Cyan

if (-not (Test-Path $profilePath)) {
    try {
        $profileDir = Split-Path $profilePath
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Host "✓ Created profile file" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create profile: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if already installed
$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
$alreadyInstalled = $profileContent -match "TheSecretJuice"

if ($alreadyInstalled) {
    Write-Host "⚠️  TheSecretJuice is already in your profile" -ForegroundColor Yellow
    $overwrite = Read-Host "   Update profile configuration? (Y/n)"
    
    if ($overwrite -eq "n" -or $overwrite -eq "N") {
        Write-Host "`n✅ Installation complete! (profile unchanged)" -ForegroundColor Green
        Write-Host "   Reload: " -NoNewline -ForegroundColor Cyan
        Write-Host ". `$PROFILE" -ForegroundColor White
        exit 0
    }
    
    # Remove old configuration
    $profileContent = $profileContent -replace "(?s)# TheSecretJuice.*?(?=`n`n|\z)", ""
    $profileContent = $profileContent.Trim()
    Set-Content -Path $profilePath -Value $profileContent
}

# Add to profile
$profileAddition = @"

# TheSecretJuice - CLI Tool Enhancements
# https://github.com/mini-page/TheSecretJuice
`$juicePath = "$scriptsPath"

# Load enhancements (uncomment to enable)
. "`$juicePath\yt-dlp-enhance.ps1"
. "`$juicePath\nav-enhance.ps1"
. "`$juicePath\robocopy-enhance.ps1"
# . "`$juicePath\fzf-enhance.ps1"      # Coming soon
# . "`$juicePath\readline-enhance.ps1" # Coming soon
"@

Add-Content -Path $profilePath -Value $profileAddition
Write-Host "✓ Added to PowerShell profile" -ForegroundColor Green

# Show available tools
Write-Host "`n🎯 Installed Enhancements:" -ForegroundColor Cyan
Write-Host "   ✅ yt-dlp-enhance     " -NoNewline -ForegroundColor Green
Write-Host "- Interactive video/audio downloader" -ForegroundColor Gray
Write-Host "   ✅ nav-enhance        " -NoNewline -ForegroundColor Green
Write-Host "- Enhanced navigation with zoxide + eza" -ForegroundColor Gray
Write-Host "   ✅ robocopy-enhance   " -NoNewline -ForegroundColor Green
Write-Host "- Smart file copying with presets" -ForegroundColor Gray

# Check for required tools
Write-Host "`n🔍 Checking for required tools..." -ForegroundColor Cyan

$tools = @{
    "yt-dlp" = "https://github.com/yt-dlp/yt-dlp/releases"
    "eza" = "https://github.com/eza-community/eza"
    "zoxide" = "https://github.com/ajeetdsouza/zoxide"
    "fzf" = "https://github.com/junegunn/fzf"
}

$missingTools = @()

foreach ($tool in $tools.Keys) {
    $found = Get-Command $tool -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host "   ✓ $tool found" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $tool not found" -ForegroundColor Yellow
        $missingTools += $tool
    }
}

if ($missingTools.Count -gt 0) {
    Write-Host "`n💡 Optional: Install missing tools for full functionality" -ForegroundColor Yellow
    foreach ($tool in $missingTools) {
        Write-Host "   $tool → " -NoNewline -ForegroundColor Gray
        Write-Host $tools[$tool] -ForegroundColor Cyan
    }
}

# Final instructions
Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        Installation Complete! 🎉         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Reload your profile:" -ForegroundColor White
Write-Host "      " -NoNewline
Write-Host ". `$PROFILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "   2. Try the enhancements:" -ForegroundColor White
Write-Host "      " -NoNewline
Write-Host "yt-help" -ForegroundColor Yellow -NoNewline
Write-Host "    - Show yt-dlp commands" -ForegroundColor Gray
Write-Host "      " -NoNewline
Write-Host "nav-help" -ForegroundColor Yellow -NoNewline
Write-Host "   - Show navigation commands" -ForegroundColor Gray
Write-Host "      " -NoNewline
Write-Host "robo-help" -ForegroundColor Yellow -NoNewline
Write-Host "  - Show robocopy commands" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Documentation:" -ForegroundColor White
Write-Host "      https://github.com/mini-page/TheSecretJuice" -ForegroundColor Cyan
Write-Host ""

Write-Host "💉 Enjoy your CLI steroids! 🚀`n" -ForegroundColor Magenta