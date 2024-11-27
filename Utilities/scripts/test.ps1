

$deploymentOutput = az deployment sub create  --location "centralindia"  --template-file D:\lab\my-test-solution\elements\res\storage\storage-account\tests\e2e\defaults\main.test.bicep

$deploymentOutput = ($deploymentOutput | ConvertFrom-Json).properties.parameters.resourceGroupName.value


$deploymentOutput