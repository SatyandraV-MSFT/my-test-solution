targetScope = 'subscription'

metadata name = 'Proximus-WAF-aligned'
metadata description = 'This instance deploys the module in alignment with the best-practices of the Well-Architected Framework.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
// e.g., for a module 'network/private-endpoint' you could use 'dep-dev-network.privateendpoints-${serviceShort}-rg'
param resourceGroupName string = 'dep-${namePrefix}-containerservice.managedclusters-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// e.g., for a module 'network/private-endpoint' you could use 'npe' as a prefix and then 'waf' as a suffix for the waf-aligned test
param serviceShort string = 'csaks'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = 'prx'

// ============ //
// Dependencies //
// ============ //

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    privateDnsZoneName: 'privatelink.${resourceLocation}.azmk8s.io'
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
    location: resourceLocation
  }
}

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      enablePrivateCluster: true
      primaryAgentPoolProfiles: [
        {
          count: 1
          enableAutoScaling: true
          maxCount: 3
          maxPods: 50
          minCount: 3
          mode: 'System'
          name: 'systempool'
          nodeTaints: [
            'CriticalAddonsOnly=true:NoSchedule'
          ]
          osDiskSizeGB: 0
          osType: 'Linux'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_DS2_v2'
          vnetSubnetResourceId: '${nestedDependencies.outputs.vNetResourceId}/subnets/defaultSubnet'
        }
      ]
      agentPools: [
        {
          count: 1
          enableAutoScaling: true
          maxCount: 3
          maxPods: 50
          minCount: 3
          minPods: 2
          mode: 'User'
          name: 'userpool1'
          nodeLabels: {}
          osDiskType: 'Ephemeral'
          osDiskSizeGB: 60
          osType: 'Linux'
          scaleSetEvictionPolicy: 'Delete'
          scaleSetPriority: 'Regular'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_DS2_v2'
          vnetSubnetResourceId: '${nestedDependencies.outputs.vNetResourceId}/subnets/defaultSubnet'
        }
        {
          count: 1
          enableAutoScaling: true
          maxCount: 3
          maxPods: 50
          minCount: 3
          minPods: 2
          mode: 'User'
          name: 'userpool2'
          nodeLabels: {}
          osDiskType: 'Ephemeral'
          osDiskSizeGB: 60
          osType: 'Linux'
          scaleSetEvictionPolicy: 'Delete'
          scaleSetPriority: 'Regular'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_DS2_v2'
        }
      ]
      autoUpgradeProfileUpgradeChannel: 'stable'
      autoNodeOsUpgradeProfileUpgradeChannel: 'Unmanaged'
      maintenanceConfigurations: [
        {
          name: 'aksManagedAutoUpgradeSchedule'
          maintenanceWindow: {
            schedule: {
              weekly: {
                intervalWeeks: 1
                dayOfWeek: 'Sunday'
              }
            }
            durationHours: 4
            utcOffset: '+00:00'
            startDate: '2024-07-15'
            startTime: '00:00'
          }
        }
        {
          name: 'aksManagedNodeOSUpgradeSchedule'
          maintenanceWindow: {
            schedule: {
              weekly: {
                intervalWeeks: 1
                dayOfWeek: 'Sunday'
              }
            }
            durationHours: 4
            utcOffset: '+00:00'
            startDate: '2024-07-15'
            startTime: '00:00'
          }
        }
      ]
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      skuTier: 'Standard'
      dnsServiceIP: '10.10.200.10'
      serviceCidr: '10.10.200.0/24'
      omsAgentEnabled: true
      disableLocalAccounts: true
      privateDNSZone: nestedDependencies.outputs.privateDnsZoneResourceId
      managedIdentities: {
        userAssignedResourcesIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    dependsOn: [
      nestedDependencies
    ]
  }
]

output resourceGroupName string = resourceGroup.name