

@description
param location string = resourceGroup().location

@description
param namePrefix string = 'hubspoke'

@description
param hubVnetAddressPrefix string = '10.0.0.0/16'

@description
param bastionSubnetPrefix string = '10.0.1.0/26'

@description
param spokeVnetAddressPrefix string = '10.1.0.0/16'

@description
param spokeWorkloadSubnetPrefix string = '10.1.1.0/24'

// ---------- Hub VNet ----------
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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
        // 
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
    ]
  }
}

// ---------- Spoke VNet ----------
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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

// ---------- Peering: Hub -> Spoke ----------
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
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

// ---------- Peering: Spoke -> Hub ----------
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
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

// ---------- Outputs ----------
output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
output spokeVnetId string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
