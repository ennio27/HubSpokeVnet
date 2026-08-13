@description('Default Location - West US 2')
param location string = resourceGroup().location

@description('Default Name Value')

param namePrefix string = 'hubspoke'

@description('Resource ID - Worload NSG - Source of diagnostic logs')
param nsgId string

@description('Resource ID - Load Balancer - Source of metric logs ')
param loadBalancerId string

@description('Name - VM - Scopes the extension resource')
param vmName string


////////


resource existingNsg 'Microsoft.Network/networkSecurityGroups@2025-07-01' existing = {
  name: '${namePrefix}-workload-nsg'
}

resource existingLb 'Microsoft.Network/loadBalancers@2025-07-01' existing = {
  name: '${namePrefix}-lb'
}


////////


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: '${namePrefix}-log-analytics'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}


resource nsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${namePrefix}-nsg-diagnostics'
  scope: existingNsg
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
      category: 'NetworkSecurityGroupEvent'
      enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}


resource lbDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${namePrefix}-lb-diagnostics'
  scope: existingLb
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}


resource existingVM 'Microsoft.Compute/virtualMachines@2026-03-01' existing = {
  name: vmName
}


resource amaExtension 'Microsoft.Compute/virtualMachines/extensions@2026-03-01' = {
  parent: existingVM
  name: 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.30'
    autoUpgradeMinorVersion: true 
  }
}

//Data Collection Rule: Tracks Performance - syslog configuration
resource DcRule 'Microsoft.Insights/dataCollectionRules@2024-03-11' = {
  name: '${namePrefix}-dc-rule'
  location: location
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'perfCounters'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Processor(_Total)\\% Processor Time'
            '\\Memory\\Available MBytes'
            
          ]
        }
      ]
      syslog: [
        {
          name: 'syslogSource'
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
            'auth'
            'authpriv'
            'daemon'
            'syslog'
          ]
          logLevels: [
            'Warning'
            'Error'
            'Critical'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'LogAnalyticsDestination'
          workspaceResourceId: logAnalyticsWorkspace.id
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
          'Microsoft-Syslog'
        ]
        destinations: [
          'LogAnalyticsDestination'
        ]
      }
    ]
  }
}


resource DcRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2024-03-11' ={
  name: '${namePrefix}-DcRule-Association'
  scope: existingVM
  properties: {
    dataCollectionRuleId: DcRule.id
  }
}


////////



output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
