//compute.bicep
//Limited to deploy 1 Linux-based VM.  
//VM access is conducted with Bastion, and reacheable through the Load Balancer's public IP


@description('Default Location - West US 2')
param location string = resourceGroup().location

@description('Default Name Value')
param namePrefix string = 'hubspoke'

@description('Resource ID - Workload Subnet')
param workloadSubnetId string

@description('Authentication type: sshPublicKey or password') //set to take CREDENTIALS
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('Username - Admin - VM')
param adminUsername string = 'azureadmin'

@description('Password - Admin - VM')
@secure()
param adminPassword string = ''

@description('SSH public key - VM')
@secure()
param adminSshPublicKey string = ''

@description('VM Size')
param vmSize string = 'Standard_E2s_v7'

@description('Toggles support for Availability Zones')
param useAvailabilityZones bool = false

@description('VM Instance Limitation')
@allowed([
  1
  2
])
param vmCount int = 2 

var allZones = ['1', '2']
var vmZones = take(allZones, vmCount)


////////


resource workloadNSG 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
    name: '${namePrefix}-workload-nsg'
    location: location
    properties: {
        securityRules: [
            {
                name: 'Allow-HTTP-Inbound'
                properties: {
                    priority: 100
                    direction: 'Inbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourcePortRange: '*'
                    destinationPortRange: '80'
                    sourceAddressPrefix: '*'
                    destinationAddressPrefix: '*'
                }
            }
            {
                name:'Allow-SSH-From-Bastion'
                properties: {
                    priority: 110
                    direction: 'Inbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourcePortRange: '*'
                    destinationPortRange: '22'
                    sourceAddressPrefix: '10.0.1.0/26' // HUB - Bastion Subnet
                    destinationAddressPrefix: '*'
                }
            }
        ]
    }
}


//Begin Load Balancer
resource lbPip 'Microsoft.Network/publicIPAddresses@2025-07-01' = {
    name: '${namePrefix}-lb-pip'
    location: location
    sku: {
        name: 'Standard'
    }
    properties: {
        publicIPAllocationMethod: 'Static'
    }
}


resource loadBalancer 'Microsoft.Network/loadBalancers@2025-07-01' = {
    name: '${namePrefix}-lb'
    location: location
    sku: {
        name: 'Standard'
    }
    properties: {
        frontendIPConfigurations: [
            {
                name: 'frontendConfig'
                properties:{
                    publicIPAddress: {
                        id: lbPip.id
                    }
                }
            }
        ]
        backendAddressPools: [
            {
                name: 'backendPool'
            }
        ]
        probes: [
            {
                name: 'httpProbe'
                properties: {
                    protocol: 'Tcp'
                    port: 80
                    intervalInSeconds: 15 
                    numberOfProbes: 2 
                }

            }
        ]
        loadBalancingRules: [
            {
                name: 'httpRule'
                properties: {
                    frontendIPConfiguration: {
                        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', '${namePrefix}-lb', 'frontendConfig')

                    }
                    backendAddressPool: {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', '${namePrefix}-lb', 'backendPool')
                    }
                    probe: {
                        id: resourceId('Microsoft.Network/loadBalancers/probes', '${namePrefix}-lb', 'httpProbe')

                    }
                    protocol: 'Tcp'
                    frontendPort: 80
                    backendPort: 80
                    idleTimeoutInMinutes: 4
                }
            }
        ]
    }
}


//VM & NIC Configuration - Spread across 2 Availability Zones 
resource nics 'Microsoft.Network/networkInterfaces@2023-09-01' = [for (zone, i) in vmZones: {
  name: '${namePrefix}-vm${i + 1}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: workloadSubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', '${namePrefix}-lb', 'backendPool')
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: workloadNSG.id
    }
  }
  dependsOn: [
    loadBalancer
  ]
}]


resource vms 'Microsoft.Compute/virtualMachines@2023-09-01' = [for (zone, i) in vmZones: {
  name: '${namePrefix}-vm${i + 1}'
  location: location
  zones: useAvailabilityZones ? [
    zone
  ] : []
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${namePrefix}vm${i + 1}'
      adminUsername: adminUsername
      adminPassword: authenticationType == 'password' ? adminPassword : null
      linuxConfiguration: authenticationType == 'sshPublicKey' ? {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      } : {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
        }
      ]
    }
  }
}]



////////


output loadBalancerPublicIp string = lbPip.properties.ipAddress
output vmNames array = [for (zone, i) in vmZones: '${namePrefix}-vm${i + 1}']
output workloadNSGId string = workloadNSG.id
output loadbalancerId string = loadBalancer.id

