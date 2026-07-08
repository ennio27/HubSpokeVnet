// main.bicep

targetScope = 'resourceGroup'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Prefix used to name resources')
param namePrefix string = 'hubspoke'

module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

output hubVnetName string = network.outputs.hubVnetName
output spokeVnetName string = network.outputs.spokeVnetName
