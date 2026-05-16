# Man-Pwsh.ps1
# Part of TheSecretJuice - Dev Pack
# Enhanced version for TheSecretJuice ecosystem

if (-not (Get-Command Write-JuiceBanner -ErrorAction SilentlyContinue)) {
    $helperPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Core\Juice-Helpers.ps1"
    if (-not (Test-Path $helperPath)) { $helperPath = Join-Path $PSScriptRoot "Juice-Helpers.ps1" } # For Core folder
    if (Test-Path $helperPath) { . $helperPath }
}

# ============================================================================
# Man for PowerShell
# ============================================================================
function Get-FormattedHelp {
    <#
    .SYNOPSIS
        Advanced manual pages for PowerShell commands with formatted output.

    .DESCRIPTION
        Enhanced Get-Help wrapper that provides Unix-like man page experience with
        color-coded, formatted output for PowerShell cmdlets, functions, and aliases.

    .PARAMETER Name
        The command name to display help for.

    .PARAMETER Full
        Display complete help including detailed descriptions and examples.

    .PARAMETER Examples
        Display only examples for the command.

    .PARAMETER Online
        Open online help in default browser.

    .PARAMETER Parameter
        Display help for a specific parameter.

    .PARAMETER Detailed
        Display detailed help including parameter descriptions.

    .PARAMETER ShowWindow
        Display help in a separate window.

    .EXAMPLE
        man Get-Process
        Displays formatted help for Get-Process

    .EXAMPLE
        man Get-Process -Full
        Displays complete detailed help

    .EXAMPLE
        man Get-Process -Examples
        Shows only examples

    .EXAMPLE
        man Get-Process -Parameter Name
        Shows help for the Name parameter
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,

        [Parameter(ParameterSetName = 'Full')]
        [switch]$Full,

        [Parameter(ParameterSetName = 'Examples')]
        [switch]$Examples,

        [Parameter(ParameterSetName = 'Online')]
        [switch]$Online,

        [Parameter(ParameterSetName = 'Parameter')]
        [string]$Parameter,

        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$Detailed,

        [Parameter(ParameterSetName = 'Window')]
        [switch]$ShowWindow
    )

    Write-JuiceBanner -Title "Command Manual"

    # Color scheme configuration
    $script:ManColors = @{
        Header    = 'Cyan'
        Section   = 'Yellow'
        Command   = 'Green'
        Parameter = 'Magenta'
        Type      = 'DarkCyan'
        Text      = 'White'
        Example   = 'Gray'
        Required  = 'Red'
        Optional  = 'DarkGray'
        Separator = 'DarkCyan'
    }

    # Helper function for colored output
    function Write-ColoredText {
        param(
            [string]$Text,
            [string]$Color = 'White',
            [int]$Indent = 0,
            [switch]$NoNewline
        )
        $padding = " " * $Indent
        if ($NoNewline) {
            Write-Host "$padding$Text" -ForegroundColor $Color -NoNewline
        }
        else {
            Write-Host "$padding$Text" -ForegroundColor $Color
        }
    }

    # Helper function for section headers
    function Write-SectionHeader {
        param([string]$Title)
        Write-Host ""
        Write-ColoredText $Title.ToUpper() -Color $script:ManColors.Section
        Write-ColoredText ("-" * $Title.Length) -Color $script:ManColors.Separator
    }

    # Helper function to format text blocks
    function Format-TextBlock {
        param(
            [Parameter(ValueFromPipeline = $true)]
            $TextObject,
            [int]$Indent = 4
        )
        process {
            if ($TextObject) {
                $text = if ($TextObject.Text) { $TextObject.Text } else { $TextObject.ToString() }     
                $lines = $text -split "`n"
                foreach ($line in $lines) {
                    $trimmed = $line.Trim()
                    if ($trimmed) {
                        Write-ColoredText $trimmed -Color $script:ManColors.Text -Indent $Indent       
                    }
                }
            }
        }
    }

    try {
        # Handle special cases
        if ($ShowWindow) {
            Get-Help $Name -ShowWindow
            return
        }

        if ($Online) {
            Get-Help $Name -Online
            return
        }

        # Get appropriate help based on parameters
        $helpParams = @{ Name = $Name }

        if ($Full) { $helpParams.Full = $true }
        elseif ($Examples) { $helpParams.Examples = $true }
        elseif ($Parameter) { $helpParams.Parameter = $Parameter }
        elseif ($Detailed) { $helpParams.Detailed = $true }

        $help = Get-Help @helpParams -ErrorAction Stop

        if (-not $help) {
            Write-ColoredText "No help found for '$Name'" -Color Red
            Write-ColoredText "Try: Update-Help to download latest help files" -Color Yellow
            return
        }

        # NAME section
        Write-SectionHeader "NAME"
        Write-ColoredText $help.Name -Color $script:ManColors.Command -Indent 4

        # SYNOPSIS
        if ($help.Synopsis) {
            Write-Host ""
            Write-ColoredText $help.Synopsis -Color $script:ManColors.Text -Indent 4
        }

        # SYNTAX section
        if ($help.Syntax.syntaxItem) {
            Write-SectionHeader "SYNTAX"
            $syntaxNum = 1
            foreach ($syntax in $help.Syntax.syntaxItem) {
                if ($help.Syntax.syntaxItem.Count -gt 1) {
                    Write-Host ""
                    Write-ColoredText "Syntax ${syntaxNum}:" -Color $script:ManColors.Example -Indent 4
                }
                Write-ColoredText $help.Name -Color $script:ManColors.Command -Indent 4 -NoNewline     

                foreach ($param in $syntax.parameter) {
                    $isRequired = $param.required -eq 'true' -or $param.required -eq $true
                    $paramColor = if ($isRequired) { $script:ManColors.Required } else { $script:ManColors.Optional }

                    if ($isRequired) {
                        Write-Host " -$($param.name)" -ForegroundColor $paramColor -NoNewline
                        Write-Host " <$($param.type.name)>" -ForegroundColor $script:ManColors.Type -NoNewline
                    }
                    else {
                        Write-Host " [-$($param.name)" -ForegroundColor $paramColor -NoNewline
                        Write-Host " <$($param.type.name)>]" -ForegroundColor $script:ManColors.Type -NoNewline
                    }
                }
                Write-Host ""
                $syntaxNum++
            }
        }

        # DESCRIPTION section
        if ($help.Description) {
            Write-SectionHeader "DESCRIPTION"
            $help.Description | Format-TextBlock
        }

        # PARAMETERS section (for Full, Detailed, or Parameter)
        if (($Full -or $Detailed -or $Parameter) -and $help.parameters.parameter) {
            Write-SectionHeader "PARAMETERS"

            foreach ($param in $help.parameters.parameter) {
                Write-Host ""
                $isRequired = $param.required -eq 'true' -or $param.required -eq $true
                $reqColor = if ($isRequired) { $script:ManColors.Required } else { $script:ManColors.Parameter }

                Write-ColoredText "-$($param.name) " -Color $reqColor -Indent 4 -NoNewline
                Write-Host "<$($param.type.name)>" -ForegroundColor $script:ManColors.Type

                # Parameter description
                if ($param.description) {
                    $param.description | Format-TextBlock -Indent 8
                }

                # Parameter metadata
                Write-Host ""
                Write-ColoredText "Required?                    $($param.required)" -Color $script:ManColors.Example -Indent 8
                Write-ColoredText "Position?                    $($param.position)" -Color $script:ManColors.Example -Indent 8
                Write-ColoredText "Default value                $($param.defaultValue)" -Color $script:ManColors.Example -Indent 8
                Write-ColoredText "Accept pipeline input?       $($param.pipelineInput)" -Color $script:ManColors.Example -Indent 8
                Write-ColoredText "Accept wildcard characters?  $($param.globbing)" -Color $script:ManColors.Example -Indent 8
            }
        }

        # INPUTS section
        if ($Full -and $help.inputTypes.inputType) {
            Write-SectionHeader "INPUTS"
            foreach ($inputType in $help.inputTypes.inputType) {
                if ($inputType.type.name) {
                    Write-ColoredText $inputType.type.name -Color $script:ManColors.Type -Indent 4     
                    if ($inputType.description) {
                        $inputType.description | Format-TextBlock -Indent 8
                    }
                }
            }
        }

        # OUTPUTS section
        if ($Full -and $help.returnValues.returnValue) {
            Write-SectionHeader "OUTPUTS"
            foreach ($returnValue in $help.returnValues.returnValue) {
                if ($returnValue.type.name) {
                    Write-ColoredText $returnValue.type.name -Color $script:ManColors.Type -Indent 4   
                    if ($returnValue.description) {
                        $returnValue.description | Format-TextBlock -Indent 8
                    }
                }
            }
        }

        # NOTES section
        if ($Full -and $help.alertSet.alert) {
            Write-SectionHeader "NOTES"
            $help.alertSet.alert | Format-TextBlock
        }

        # EXAMPLES section
        if (($Examples -or $Full -or $Detailed) -and $help.examples.example) {
            Write-SectionHeader "EXAMPLES"
            $exampleNum = 1

            foreach ($example in $help.examples.example) {
                Write-Host ""
                Write-ColoredText "-------------------------- EXAMPLE $exampleNum --------------------------" -Color $script:ManColors.Separator -Indent 4
                Write-Host ""

                if ($example.title) {
                    Write-ColoredText ($example.title -replace '^-+\s*', '') -Color $script:ManColors.Command -Indent 4
                }

                if ($example.code) {
                    Write-ColoredText "PS C:\> " -Color $script:ManColors.Command -Indent 4 -NoNewline 
                    Write-Host $example.code -ForegroundColor $script:ManColors.Command
                }

                if ($example.remarks) {
                    Write-Host ""
                    $example.remarks | Format-TextBlock -Indent 4
                }

                $exampleNum++
            }
        }

        # RELATED LINKS section
        if ($help.relatedLinks.navigationLink) {
            Write-SectionHeader "RELATED LINKS"
            foreach ($link in $help.relatedLinks.navigationLink) {
                if ($link.uri) {
                    Write-ColoredText $link.uri -Color $script:ManColors.Command -Indent 4
                }
                elseif ($link.linkText) {
                    Write-ColoredText $link.linkText -Color $script:ManColors.Command -Indent 4        
                }
            }
        }

        # ALIASES section
        $aliases = Get-Alias -Definition $help.Name -ErrorAction SilentlyContinue
        if ($aliases) {
            Write-SectionHeader "ALIASES"
            $aliasNames = ($aliases | ForEach-Object { $_.Name }) -join ", "
            Write-ColoredText $aliasNames -Color $script:ManColors.Command -Indent 4
        }

        # Footer with usage tips
        Write-Host ""
        Write-ColoredText "  QUICK REFERENCE" -Color $script:ManColors.Header -Indent 2
        Write-ColoredText "man $Name -Full       " -Color $script:ManColors.Example -Indent 4 -NoNewline
        Write-Host "Complete documentation with all details"
        Write-ColoredText "man $Name -Examples   " -Color $script:ManColors.Example -Indent 4 -NoNewline
        Write-Host "Show usage examples only"
        Write-ColoredText "man $Name -Online     " -Color $script:ManColors.Example -Indent 4 -NoNewline
        Write-Host "Open online help in browser"
        Write-ColoredText "man $Name -Detailed   " -Color $script:ManColors.Example -Indent 4 -NoNewline
        Write-Host "Detailed help with parameter info"
        Write-ColoredText "man $Name -ShowWindow " -Color $script:ManColors.Example -Indent 4 -NoNewline
        Write-Host "Open help in separate window"
        Write-Host ""

    }
    catch {
        Write-ColoredText "Error: Unable to retrieve help for '$Name'" -Color Red
        Write-ColoredText "Details: $($_.Exception.Message)" -Color Red
        Write-Host ""
        Write-ColoredText "Suggestions:" -Color Yellow
        Write-ColoredText "• Check if the command exists: Get-Command $Name" -Color $script:ManColors.Example -Indent 2
        Write-ColoredText "• Update help files: Update-Help -Force" -Color $script:ManColors.Example -Indent 2
        Write-ColoredText "• Try: Get-Help $Name" -Color $script:ManColors.Example -Indent 2
    }
}

# Create aliases
Set-Alias -Name man -Value Get-FormattedHelp -Option AllScope -Force -ErrorAction SilentlyContinue     
Set-Alias -Name Man -Value Get-FormattedHelp -Option AllScope -Force -ErrorAction SilentlyContinue     
