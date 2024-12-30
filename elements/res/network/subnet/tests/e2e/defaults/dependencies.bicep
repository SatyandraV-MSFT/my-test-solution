@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the Virtual Network (vNet).')
param virtualNetworkName string = 'testvirtualnetwork'

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array = ['10.0.0.0/16']

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

@description('The resource ID of the created virtual Network.')
output virtualNetworkResourceId string = virtualNetwork.id
