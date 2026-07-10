// main.bicep
<<<<<<< HEAD
// "The Hub"

//
targetScope = 'resourceGroup'

@description('Generic Location parameter - East US')
=======

targetScope = 'resourceGroup'

@description('Azure region for all resources')
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
param location string = resourceGroup().location

@description('Prefix used to name resources')
param namePrefix string = 'hubspoke'

<<<<<<< HEAD

//
=======
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

<<<<<<< HEAD
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
=======
output hubVnetName string = network.outputs.hubVnetName
output spokeVnetName string = network.outputs.spokeVnetName
>>>>>>> 5c41108813f35e63f05f97470b0f876070e7fba0
