

$deploymentOutput = az deployment sub create  --location "centralindia"  --template-file D:\lab\my-test-solution\elements\res\storage\storage-account\tests\e2e\defaults\main.test.bicep

$deploymentOutput = ($deploymentOutput | ConvertFrom-Json).properties.parameters.resourceGroupName.value


$deploymentOutput

$MODULE_NAME = "storage/storage-account/0.14.3" #"${{ github.event.inputs.module }}"

# Extract ResourceProvider and Resource from the module path
$VERSION = $MODULE_NAME.Split('/')[2]
$RESOURCE_PROVIDER = $MODULE_NAME.Split('/')[0]  # Extract the third part of the path (network in this case)
$RESOURCE = $MODULE_NAME.Split('/')[1]           # Extract the fourth part of the path (e.g., subnet, private-endpoint)

# Correct the source and destination directories
$SOURCE_DIR = "bicep-registry-modules/avm/res/$RESOURCE_PROVIDER/$RESOURCE"
$DEST_DIR = "elements/res/$RESOURCE_PROVIDER/$RESOURCE"
echo "MODULE_NAME=$DEST_DIR" >> $GITHUB_ENV
Write-Output "Copying module from: $SOURCE_DIR to: $DEST_DIR"

# Create the destination directory structure
New-Item -ItemType Directory -Force -Path $DEST_DIR

# Check if the source directory exists in the external repo
if (Test-Path -Path $SOURCE_DIR) {
  Copy-Item -Path "$SOURCE_DIR\*" -Destination $DEST_DIR -Recurse -Force
  Write-Output "Copy completed successfully."
  Remove-Item -Force -Path "bicep-registry" -Confirm:$false -Recurse
} else {
  Write-Error "Error: Source directory '$SOURCE_DIR' does not exist."
  exit 1
}

Write-Output "Listing copied files in destination directory:"
Get-ChildItem -Path $DEST_DIR -Recurse 
TREE $DEST_DIR /F

          $isPull_Request = "${{ github.event_name == 'pull_request' }}"
          $isWorkflow_Dispatch = "${{ github.event_name == 'workflow_dispatch' }}"

          if ($isPull_Request)
          {
            $commitMessages = git log --format=%B --no-merges origin/${{ github.event.pull_request.head.ref }}          
            write-host "This is a Pull Request Trigger and Commit Message: $($commitMessages)"
            if ($commitMessages -match 'remove_deployment=false' ) {
              "remove_deployment=false" | Out-File -FilePath $env:GITHUB_ENV -Append
            } else { "remove_deployment=true" | Out-File -FilePath $env:GITHUB_ENV -Append }
          }
          else ($isWorkflow_Dispatch)
          {
            $workflow_dispatch = "${{ inputs.remove_deployment }}"
            write-host "This is a Workflow Dispatch Trigger and Input Option: $($workflow_dispatch)"
            if($workflow_dispatch -eq 'false') {
              "remove_deployment=false" | Out-File -FilePath $env:GITHUB_ENV -Append
            } else { "remove_deployment=true" | Out-File -FilePath $env:GITHUB_ENV -Append }
          } finally { "remove_deployment=true" | Out-File -FilePath $env:GITHUB_ENV -Append }


           
          else {

          }
          finally { "remove_deployment=true" | Out-File -FilePath $env:GITHUB_ENV -Append }


