// bastion.bicep
// Deploys Azure Bastion to the main hub's AzureBastionSubnet


//
@description('Prefix to name resources')
param namePrefix string = 'hubspoke'

@description('Generic Location parameter - East US')
param location string = resourceGroup().location

@description('Resource ID of the AzureBastionSubnet - for the main hub Vnet')
param bastionSubnetId string 


//
resource bastionPIP 'Microsoft.Network/publicIPAddresses@2025-07-01' = {
    name: '${namePrefix}-bastion-pip'
    location: location
    sku: {
        name: 'Standard'
        
    }
    properties: {
        publicIPAllocationMethod: 'Static'
    }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2025-07-01' = {
    name:'${namePrefix}-bastion' 
    location: location
    sku: {
        name: 'Basic'
    }
    properties: {
        ipConfigurations: [
            {
                name: 'bastionIPConfig'
                properties: {
                    subnet: {
                        id: bastionSubnetId
                    }
                    publicIPAddress: {
                        id: bastionPIP.id
                    }
                }
            }
        ]
    }

}


//
output bastionHostId string = bastionHost.id
output bastionHostName string = bastionHost.name




