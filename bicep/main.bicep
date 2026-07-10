// main.bicep
// "The Hub"

//
targetScope = 'resourceGroup'

@description('Generic Location parameter - East US')
param location string = resourceGroup().location

@description('Prefix used to name resources')
param namePrefix string = 'hubspoke'


//
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

//
module bastion 'modules/bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    bastionSubnetId: '${network.outputs.hubVnetId}/subnets/AzureBastionSubnet'
  }


}


//
output hubVnetName string = network.outputs.hubVnetName
output spokeVnetName string = network.outputs.spokeVnetName
output bastionHostName string = bastion.outputs.bastionHostName
