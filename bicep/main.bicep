// main.bicep
// "The Hub"

//
targetScope = 'resourceGroup'

@description('Generic Location parameter - West US 2')
param location string = resourceGroup().location

@description('Prefix used to name resources')
param namePrefix string = 'hubspoke'

@description('VM admin username')
param adminUsername string = 'azureadmin'

@description('VM admin password')
@secure()
param adminPassword string = ''

@description('Sets Authentication Method') //Set to password
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH public key')
@secure()
param adminSshPublicKey string = ''

@description('Enables/Disables support for Availability Zones')
param useAvailabilityZones bool = false 

@description('Limits the number of VMs that can be deployed')
@allowed([
  1
  2
])
param vmCount int = 1 


//
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

module bastion 'modules/bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    bastionSubnetId: '${network.outputs.hubVnetId}/subnets/AzureBastionSubnet'
  }
}

module compute 'modules/compute.bicep' = {
  name: 'computeDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    workloadSubnetId: '${network.outputs.spokeVnetId}/subnets/workload-subnet'
    adminUsername: adminUsername
    adminPassword: adminPassword
    adminSshPublicKey: adminSshPublicKey
    authenticationType: authenticationType
    UseAvailabilityZones: useAvailabilityZones
    vmCount: vmCount
  }
}


//
output hubVnetName string = network.outputs.hubVnetName
output spokeVnetName string = network.outputs.spokeVnetName
output bastionHostName string = bastion.outputs.bastionHostName
output loadBalancerPublicIp string = compute.outputs.loadBalancerPublicIp
output vmNames array = compute.outputs.vmNames
