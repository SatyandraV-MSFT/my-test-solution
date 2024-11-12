targetScope = 'subscription'

metadata description = 'ACR deployment with a credential set and a cache rule.'

// ========== //
// Parameters //
// ========== //

@description('Optional. rootName')
param client string = 'Pxs'

@description('Optional. deploymentPrefix')
param workloadidentifier string = 'myt'

@description('Optional. deploymentPrefix')
param purpose string = 'inf'

@description('Optional. deploymentPrefix')
param env string = 's'

@description('Optional. deploymentPrefix')
param region string = 'we'

@description('Optional. deploymentPrefix')
param resourcetype string = 'acr'

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = '${client}-${workloadidentifier}-${purpose}-${env}-${region}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

// ============ //
// Dependencies //
// ============ //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// module acr 'acr.bicep' = {

module acrModule 'acr.bicep' = {
  scope: resourceGroup
  name: 'DeployACRModule'
  params: {
    location: resourceLocation
    acrName: '${client}${workloadidentifier}${purpose}${env}${region}${resourcetype}1'
  }
}

module acr_cache 'cacherule.bicep' = {
  scope: resourceGroup
  dependsOn: [acrModule]
  name: 'Procontainer'
  params: {
    acrName: '${client}${workloadidentifier}${purpose}${env}${region}${resourcetype}1'
  }
}
