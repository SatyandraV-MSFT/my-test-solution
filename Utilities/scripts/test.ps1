

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