<#
.SYNOPSIS
    This script performs a specific task (provide a brief description of what the script does).

.DESCRIPTION
    This script is designed to (provide a detailed description of the script's functionality and purpose).
    It takes (mention any inputs or parameters) and produces (mention any outputs or results).

.PARAMETER <ParameterName>
    Description of the parameter and its purpose.

.EXAMPLE
    Provide an example of how to use the script.
    PS> .\YourScript.ps1 -ParameterName value

.NOTES
    Author: Your Name
    Date: Date of creation or modification
    Version: Version of the script
    Additional notes or information

#>
param (
    [Parameter(Mandatory = $false)]
    [string] $yamlFilePath = '.github\workflows\onboarding-workflow.yml',
    [Parameter(Mandatory = $true)]
    [array] $newOptions
)

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

if (-not $yamlFilePath) {
    Write-Error 'YAML file path is required.'
    exit 1
}

if (-not $newOptions) {
    Write-Error 'New options are required.'
    exit 1
}

# Load YAML content and clean
$yamlContent = Get-Content -Raw -Path "$yamlFilePath" | ConvertFrom-Yaml

if ($yamlContent -and $yamlContent.on.workflow_dispatch.inputs.module_path.options) {
    # Append new options and remove duplicates
    $cleanedOptions = $newOptions | ForEach-Object {
        $_.Trim() -replace '["''\[\]]', '' # Remove unwanted characters
    } | Select-Object -Unique

    $yamlContent.on.workflow_dispatch.inputs.module_path.options = $cleanedOptions
    $yamlContent | ConvertTo-Yaml | Set-Content -Path $yamlFilePath

    Write-Host 'YAML file updated successfully!'
} else {
    Write-Error "Invalid YAML structure or missing 'options' key."
    exit 1
}
