// network.bicep
// Deploys a Hub VNet (with AzureBastionSubnet) and a Spoke VNet (with a workload subnet),


@description('Generic Location parameter - East US')
param location string = resourceGroup().location

@description('Prefix to name resources')
param namePrefix string = 'hubspoke'

@description('Address space - hub VNet')
param hubVnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix - AzureBastionSubnet')
param bastionSubnetPrefix string = '10.0.1.0/26'

@description('Address space - spoke VNet')
param spokeVnetAddressPrefix string = '10.1.0.0/16'

@description('Address prefix - spoke workload subnet')
param spokeWorkloadSubnetPrefix string = '10.1.1.0/24'


// 
resource hubVnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: '${namePrefix}-hub-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
    ]
  }
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: '${namePrefix}-spoke-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'workload-subnet'
        properties: {
          addressPrefix: spokeWorkloadSubnetPrefix
        }
      }
    ]
  }
}

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  parent: hubVnet
  name: 'hub-to-spoke'
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  parent: spokeVnet
  name: 'spoke-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
output spokeVnetId string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
