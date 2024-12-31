# Prerequisites for Set-AVMModule

- Modules or Patterns should follow th AKA.MS/BRM folder structure.
- Needs root directory to be avm/res/ [in Proximus environment, rename the elements folder to avm before executing the script.]
- Dependency scripts -> pipelines/sharedScripts and /helper

## Navigation

- [Execution Steps](#Execution Steps)

## Execution Steps

1. Windows: open PowerShell Console | Linux: Open pwsh
2. load AVM Script: . /home/savishwa/pxs/azure_avm_iac_elements/utilities/tools/Set-AVMModule.ps1
3. run AVM function with module folder path: Set-AVMModule -ModuleFolderPath /xxx/azure_avm_iac_elements/avm/res/network/virtual-network -Recurse
