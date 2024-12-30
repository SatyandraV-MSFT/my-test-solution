<#
.SYNOPSIS
    Retrieves a list of modules from the Microsoft Container Registry (MCR).

.DESCRIPTION
    This script fetches and displays a list of available modules from the Microsoft Container Registry (MCR).
    It is useful for identifying and managing modules that can be used in various Azure projects.

.PARAMETER None
    This script does not take any parameters.

.EXAMPLE
    .\Get-ModuleListFromMcr.ps1
    Retrieves and displays the list of modules from MCR.

.NOTES
    Author: Savishwa
    FilePath: /c:/Users/savishwa/OneDrive - Microsoft/Project_Related/Proximus/Repo/azure_avm_iac_elements/utilities/tools/Get-ModuleListFromMcr.ps1
    Requires: PowerShell 5.1 or later

#>
param (
    [Parameter(Mandatory = $false)]
    [string] $RegistryUrl = 'https://mcr.microsoft.com/v2',
    [Parameter(Mandatory = $false)]
    [string] $ModuleRepoPath = 'bicep/avm/res'
)

# Construct the URL to fetch the catalog of repositories from the registry
$catalogUrl = "$($RegistryUrl)/_catalog"
$moduleListOutput = [System.Collections.ArrayList]::new()

try {
    $catalogContentRaw = (Invoke-WebRequest -Uri $catalogUrl -UseBasicParsing).Content
    $bicepCatalogContent = ($catalogContentRaw | ConvertFrom-Json).repositories | Select-String $ModuleRepoPath | Select-Object -Unique

    if ($bicepCatalogContent) {
        foreach ($module in $bicepCatalogContent) {
            if ($module) {
                $moduleVersionUrl = "$($RegistryUrl)/$($module)/tags/list"
                $moduleVersions = Invoke-WebRequest -Uri $moduleVersionUrl
                $moduleVersions | ConvertFrom-Json | Select-Object -ExpandProperty tags | ForEach-Object {
                    $versionTag = "$($module)/$($_)".Replace('bicep/avm/res/', '').Trim()
                    $moduleListOutput.Add($versionTag) | Out-Null
                }
            }
        }
        return $moduleListOutput
    }
} catch {
    Write-Error ('Unable to fetch the modules: {0}' -f $_.Exception.Message)
}
