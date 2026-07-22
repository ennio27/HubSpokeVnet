//compute.bicep
//Deploys 2 Linux-based VMs. 
//No Public IPs; Vms are spread across Availability Zones 1 and 2. 
//VMs are reachable exclusively through Bastion, and via the Load Balancer's public IP


//
@description('Generic Location parameter - East US')
param location string = resourceGroup().location

@description('Prefix used to name resources')
param namePrefix string = 'hubspoke'

@description('Resource ID - Workload Subnet')
param workloadSubnetId string

@description('Authentication type: sshPublicKey or password')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('VM - Admin Username')
param adminUsername string = 'azureadmin'

@description('VM admin password')
@secure()
param adminPassword string = ''

@description('SSH public key for VM Admin login')
@secure()
param adminSshPublicKey string = ''

@description('VM Size')
param vmSize string = 'Standard_E2s_v7'

@description('Set to true only if the region supports Availability Zones')
param UseAvailabilityZones bool = false

@description('Limits the number of VMs that can be deployed')
@allowed([
  1
  2
])
param vmCount int = 1 

var allZones = ['1', '2']
var vmZones = take(allZones, vmCount)



//
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
resource nics 'Microsoft.Network/networkInterfaces@2025-07-01' = [for (zone, i) in vmZones: {
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
}
]

resource vms 'Microsoft.Compute/virtualMachines@2023-09-01' = [for (zone, i) in vmZones: {
    name: '${namePrefix}-vm${i + 1}'
    location: location
    zones: UseAvailabilityZones ? [
        zone
    ] : [

    ]
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        osProfile: {
            computerName: '${namePrefix}-vm${i + 1}'
            adminUsername: adminUsername
            adminPassword: authenticationType == 'password' ? adminPassword : null
            linuxConfiguration: authenticationType == 'sshPublicKey' ? {
                disablePasswordAuthentication: true 
                ssh: {
                    publicKeys: [
                        {
                            path: '/Users/junior jon/$HOME/.ssh'
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
}
]

output loadBalancerPublicIp string = lbPip.properties.ipAddress
output vmNames array = [for (zone, i) in vmZones: '${namePrefix}-vm${i + 1}']
