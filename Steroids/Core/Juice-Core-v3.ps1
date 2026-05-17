# Juice-Core-v3.ps1
# Minimal Base Core for TheSecretJuice v3.0
# Optimized for high-speed boot.

$script:Juice = [pscustomobject]@{
    Version = "3.0.0-alpha"
    ModulesPath = Split-Path $PSScriptRoot -Parent
    SuggestionsEnabled = $true
    ActiveSteroids = @()
    BackgroundLoader = $null
    ShownSuggestions = @{}
}

function juice {
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    Write-Host "The Secret Juice v$($script:Juice.Version) - Base Active" -ForegroundColor Magenta
}

Write-Host "💉 Base Core Loaded" -ForegroundColor Green
