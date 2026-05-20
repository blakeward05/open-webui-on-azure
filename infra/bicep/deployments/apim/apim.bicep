// APIM Module
targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'


// ========== MARK: Parameters ==========
param parApimName string
param parApimPublicIpName string
param parApimSku string
param parApimSubnetName string
param parAppRegistrationName string
param parFoundryEndpoint string
param parHubAppInsightsName string
param parHubLogAnalyticsWorkspaceName string
param parHubResourceGroupName string
param parHubVirtualNetworkName string
param parLocation string
param parMonitoringMetricsRole string
param parPublisherEmail string
param parPublisherName string


// ========== MARK: Existing Resource ==========
resource logHubAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubLogAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubAppInsightsName
}

resource appRegistration 'Microsoft.Graph/applications@v1.0' existing = {
  uniqueName: parAppRegistrationName
}

resource appApimPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parApimPublicIpName
  }

resource hubVirtualNet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubVirtualNetworkName
}

resource appApimSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  name: parApimSubnetName
  parent: hubVirtualNet
}


// ========== MARK: Variables ==========
var parHubLogAnalyticsId = logHubAnalytics.id
var parHubAppInsightsId = appInsights.id
var parHubAppInsightsConnString = appInsights.properties.ConnectionString
var parAppRegistrationId = appRegistration.id
var parApimSubnetResourceId = appApimSubnet.id
var parApimPublicIpResourceId = appApimPublicIp.id



// Conditional backend - only create when Foundry endpoint is provided
var varFoundryBackends = [
  {
    name: 'foundry-backend'
    protocol: 'http'
    url: '${parFoundryEndpoint}/openai/v1'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
]

// Load policy file
var varOpenAIPolicyXml = loadTextContent('../../policies/openai-api.xml')

// API Management Service - Base infrastructure
module modApim 'br/public:avm/res/api-management/service:0.14.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parApimName
    publisherEmail: parPublisherEmail
    publisherName: parPublisherName
    location: parLocation
    sku: parApimSku  //keep an eye on this for what is needed cost wise
    virtualNetworkType: 'Internal' //internal requires specific sku
    subnetResourceId: parApimSubnetResourceId
    publicIpAddressResourceId: parApimPublicIpResourceId
    backends: varFoundryBackends
    loggers: [
      {
        name: parHubAppInsightsName
        type: 'applicationInsights'
        description: 'Logger for Application Insights'
        targetResourceId: parHubAppInsightsId
        credentials: {
          connectionString: parHubAppInsightsConnString
          identityClientId: 'systemAssigned'
        }
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
    diagnosticSettings: [
      {
        name: 'apim-diagnostics'
        workspaceResourceId: parHubLogAnalyticsId
        logAnalyticsDestinationType: 'Dedicated'
        logCategoriesAndGroups: [
            {
            category: 'GatewayLogs'
            enabled: true
            }
            {
            category: 'GatewayLlmLogs'
            enabled: true
            }
        ]
      }
    ]
  }
}

// Named values let you define common values or secrets in your API Management instance, which can be referenced from policies.
// Named Values - Deploy first so APIs can reference them in policies
module modApimNamedValueTenantId 'br/public:avm/res/api-management/service/named-value:0.1.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    apiManagementServiceName: parApimName
    name: 'tenant-id'
    displayName: 'tenant-id'
    secret: false
    value: tenant().tenantId
  }
  dependsOn: [
    modApim
  ]
}

// Named value for Open WebUI App ID - always created, uses placeholder if not yet configured
module modApimNamedValueAppId 'br/public:avm/res/api-management/service/named-value:0.1.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    apiManagementServiceName: parApimName
    name: 'openwebui-app-id'
    displayName: 'openwebui-app-id'
    secret: false
    value: parAppRegistrationId 
  }
  dependsOn: [
    modApim
  ]
}

// Product - Deploy before API so API can reference it
module modApimProduct 'br/public:avm/res/api-management/service/product:0.1.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    apiManagementServiceName: parApimName
    name: 'platform-services'
    displayName: 'Platform Services'
    description: 'AI and ML services managed by Platform Engineering team'
    subscriptionRequired: true
    approvalRequired: false
    state: 'published'
  }
  dependsOn: [
    modApim
  ]
}

// API - Deploy after named values and product exist
// This is the specific settings needed to use the foundry services in openweb ui
module modApimApi 'br/public:avm/res/api-management/service/api:0.1.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    apiManagementServiceName: parApimName
    name: 'openai'
    displayName: 'Azure OpenAI v1 API'
    path: 'openai/v1'
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: true
    subscriptionKeyParameterNames: {
      header: 'api-key'
    }
    policies: [
      {
        format: 'rawxml'
        value: varOpenAIPolicyXml
      }
    ]
  }
  dependsOn: [
    modApimNamedValueTenantId
    modApimNamedValueAppId
    modApimProduct
  ]
}

// API-Product Association - Deploy after both API and Product exist
module modApimProductApi 'br/public:avm/res/api-management/service/product/api:0.1.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    apiManagementServiceName: parApimName
    productName: 'platform-services'
    name: 'openai'
  }
  dependsOn: [
    modApimApi
    modApimProduct
  ]
}

// RBAC for APIM to publish metrics to App Insights
module modApimMetricsPublisherRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    principalId: modApim.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
    roleDefinitionId: parMonitoringMetricsRole
    resourceId: parHubAppInsightsId
  }
}

// MARK: - API Logging - calls another module because needs to run at resource group level
module modOpenAILogging './apim_logging.bicep' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    parApimName: parApimName
    parHubAppInsightsName: parHubAppInsightsName
  }
  dependsOn: [
    modApimApi
  ]
}


/*
// Outputs
output resourceId string = modApim.outputs.resourceId
output name string = modApim.outputs.name
output gatewayUrl string = 'https://${modApim.outputs.name}.azure-api.net'
output systemAssignedMIPrincipalId string = modApim.outputs.systemAssignedMIPrincipalId!
*/
