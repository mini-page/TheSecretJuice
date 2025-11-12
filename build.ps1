# Install required modules if they are not already present
$requiredModules = @("PSYaml", "Microsoft.PowerShell.Markdown")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module '$module'..."
        Install-Module -Name $module -Repository PSGallery -Force -Scope CurrentUser
    }
}

function Convert-MarkdownToHtmlWithTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$MarkdownFilePath,

        [Parameter(Mandatory=$true)]
        [string]$TemplateFilePath
    )

    # Read Markdown content
    $markdownContent = Get-Content -Path $MarkdownFilePath -Raw

    # Extract front matter
    $frontMatter = $null
    $body = $markdownContent
    if ($markdownContent -match '(?s)---(.*?)---(.*)') {
        $frontMatterText = $matches[1]
        $body = $matches[2]
        $frontMatter = ConvertFrom-Yaml -Yaml $frontMatterText
    }

    # Convert Markdown body to HTML
    $convertedHtml = ConvertFrom-Markdown -InputObject $body
    $htmlBody = $convertedHtml.Html

    # Read the HTML template
    $templateContent = Get-Content -Path $TemplateFilePath -Raw

    # Determine the title
    $title = "TheSecretJuice"
    if ($frontMatter -and $frontMatter.title) {
        $title = $frontMatter.title
    }

    # Replace placeholders in the template
    $finalHtml = $templateContent.Replace("{{title}}", $title)
    $finalHtml = $finalHtml.Replace("{{content}}", $htmlBody)

    # Generate output file path
    $outputHtmlFilePath = [System.IO.Path]::ChangeExtension($MarkdownFilePath, ".html")

    # Save the final HTML to the output file
    Set-Content -Path $outputHtmlFilePath -Value $finalHtml -Encoding UTF8

    Write-Host "Successfully converted '$MarkdownFilePath' to '$outputHtmlFilePath'."
}

# Find all Markdown files in the docs directory
$markdownFiles = Get-ChildItem -Path "docs" -Recurse -Filter "*.md"

# Get the template file path
$templateFile = "docs/_layout/_layout.html"

# Convert each Markdown file
foreach ($file in $markdownFiles) {
    Convert-MarkdownToHtmlWithTemplate -MarkdownFilePath $file.FullName -TemplateFilePath $templateFile
}