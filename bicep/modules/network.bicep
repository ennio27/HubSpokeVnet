<<<<<<< HEAD
// network.bicep
// "The Spoke"
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
=======


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
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
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
<<<<<<< HEAD
=======
        // 
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
    ]
  }
}

<<<<<<< HEAD
resource spokeVnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
=======
// ---------- Spoke VNet ----------
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
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

<<<<<<< HEAD
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
=======
// ---------- Peering: Hub -> Spoke ----------
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
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

<<<<<<< HEAD
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
=======
// ---------- Peering: Spoke -> Hub ----------
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
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

<<<<<<< HEAD

=======
// ---------- Outputs ----------
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
output spokeVnetId string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
