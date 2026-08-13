// main.bicep


targetScope = 'resourceGroup'

@description('Default Location - West US 2')
param location string = resourceGroup().location

@description('Default Name Value')
param namePrefix string = 'hubspoke'

@description('Username - Admin - VM')
param adminUsername string = 'azureadmin'

@description('Password - Admin - VM')
@secure()
param adminPassword string = ''

@description('Authentication Method') //set to take CREDENTIALS
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH public key - VM')
@secure()
param adminSshPublicKey string = ''

@description('Toggles support for Availability Zones')
param useAvailabilityZones bool = false 

@description('VM Instance Limitation')
@allowed([
  1
  2
])
param vmCount int = 1 


////////


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
    useAvailabilityZones: useAvailabilityZones
    vmCount: vmCount
  }
}


module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    nsgId: compute.outputs.workloadNSGId
    loadBalancerId: compute.outputs.loadBalancerPublicIp
    vmName: compute.outputs.vmNames[0]
  }
}


////////


output hubVnetName string = network.outputs.hubVnetName
output spokeVnetName string = network.outputs.spokeVnetName
output bastionHostName string = bastion.outputs.bastionHostName
output loadBalancerPublicIp string = compute.outputs.loadBalancerPublicIp
output vmNames array = compute.outputs.vmNames
output logAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsWorkspaceName
