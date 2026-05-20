//creates resource groups for hub and spoke, key vaults for hub and spoke
//storage account for countainer to mount

targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== Type Imports ==========
import { TagsType } from '../../shared/types.bicep'


// ========== MARK: Parameters ==========
param parAcaNsgName string
param parAcaSubnetAddressPrefix string
param parAcaSubnetName string
param parApimDnsName string
param parApimNsgName string
param parApimPublicIpName string
param parApimRouteName string
param parApimSubnetAddressPrefix string
param parApimSubnetName string
param parAppGatewayDnsName string
param parAppGatewaySubnetAddressPrefix string
param parAppGwPublicIpName string
param parAppGwSubnetName string
param parHubAppInsightsName string
param parHubEnvManagedId string
param parHubKeyVaultName string
param parHubLogAnalyticsWorkspaceName string
param parHubResourceGroupName string
param parHubVirtualNetworkAddressPrefix string
param parHubVirtualNetworkName string
param parKeyVaultAdminIdRole string
param parKeyVaultUserIdRole string
param parLocation string
param parPeSubnetAddressPrefix string
param parPeSubnetName string
param parShareName string
param parSpokeAppInsightsName string
param parSpokeEnvManagedId string
param parSpokeKeyVaultName string
param parSpokeLogAnalyticsWorkspaceName string
param parSpokeResourceGroupName string
param parSpokeVirtualNetworkAddressPrefix string
param parSpokeVirtualNetworkName string
param parStorageAccountName string




var parTags TagsType = {
  Application: 'Open WebUI'
  Environment: 'Demo'
  Owner: 'Blake Ward'
}




// MARK: - Resource Group
module modHubResourceGroup 'br/public:avm/res/resources/resource-group:0.4.2' = {
  params: {
    name: parHubResourceGroupName
    location: parLocation
    tags: parTags
  }
}

module modSpokeResourceGroup 'br/public:avm/res/resources/resource-group:0.4.2' = {
  params: {
    name: parSpokeResourceGroupName
    location: parLocation
    tags: parTags
  }
}


// MARK: - Key Vault
module modHubKeyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubKeyVaultName
    location: parLocation
    sku: 'standard'
    enablePurgeProtection: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
  dependsOn: [modHubResourceGroup]
}

module modSpokeKeyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parSpokeKeyVaultName
    location: parLocation
    sku: 'standard'
    enablePurgeProtection: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
  dependsOn: [modSpokeResourceGroup]
}



// MARK: - Hub Log Analytics Workspace
module modHubLogAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.13.0' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubLogAnalyticsWorkspaceName
    location: parLocation
    skuName: 'PerGB2018'
    dailyQuotaGb: 1
    dataRetention: 30
    features: {
      disableLocalAuth: true
    }
  }
  dependsOn: [
    modHubResourceGroup
  ]
}


// MARK: - Spoke Log Analytics Workspace
module modSpokeLogAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.13.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parSpokeLogAnalyticsWorkspaceName
    location: parLocation
    skuName: 'PerGB2018'
    dailyQuotaGb: 1
    dataRetention: 30
    features: {
      disableLocalAuth: true
    }
  }
  dependsOn: [
    modSpokeResourceGroup
  ]
}

// MARK: - Hub Application Insights
module modHubAppInsights 'br/public:avm/res/insights/component:0.7.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubAppInsightsName
    location: parLocation
    workspaceResourceId: modHubLogAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    disableLocalAuth: true
    kind: 'web'
  }
  dependsOn: [modHubResourceGroup]
}

// MARK: - Spoke Application Insights
module modSpokeAppInsights 'br/public:avm/res/insights/component:0.7.1' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parSpokeAppInsightsName
    location: parLocation
    workspaceResourceId: modSpokeLogAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    disableLocalAuth: true
    kind: 'web'
  }
  dependsOn: [modSpokeResourceGroup]
}

// Managed Identity for Application Gateway
module modAppGatewayIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' =  {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubEnvManagedId
    location: parLocation
  }
    dependsOn: [modHubResourceGroup]
}


// MARK: - RBAC for Application Gateway Vault
module modAppGatewayKeyVaultRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = { //if (!empty(parCustomDomain)) {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    principalId: modAppGatewayIdentity.outputs.principalId
    resourceId: modHubKeyVault.outputs.resourceId
    roleDefinitionId: parKeyVaultUserIdRole
  }
}

// MARK: - Spoke Container App Environment Managed Identity
module modEnvIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parSpokeEnvManagedId
    location: parLocation
  }
   dependsOn: [modSpokeResourceGroup]
}

// MARK: - RBAC for Environment Identity Vault
module modEnvKeyVaultRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    principalId: modEnvIdentity.outputs.principalId
    roleName: 'Key Vault Secrets User'
    resourceId: modSpokeKeyVault.outputs.resourceId
    roleDefinitionId: parKeyVaultUserIdRole
    principalType: 'ServicePrincipal'
  }
}


// MARK: - RBAC for Environment Identity Vault for Deployer as Admin
module modEnvKeyVaultAdminRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    principalId: az.deployer().objectId
    roleName: 'Key Vault Administrator'
    resourceId: modSpokeKeyVault.outputs.resourceId
    roleDefinitionId: parKeyVaultAdminIdRole
  }
}

// MARK: - RBAC for Application Gateway Vault for Deployer as Admin
module modAppGatewayKeyVaultAdminRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = { //if (!empty(parCustomDomain)) {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    principalId: az.deployer().objectId
    resourceId: modHubKeyVault.outputs.resourceId
    roleDefinitionId: parKeyVaultAdminIdRole
  }
}


// ============= NETWORING PART ===============================



// MARK: Network Security for NSG for APIM Subnet
module modNsgApim 'br/public:avm/res/network/network-security-group:0.5.2' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parApimNsgName
    location: parLocation
    securityRules: varNsgRules
  }
}

// MARK: - Network Security Group for Container App
module modNsgContainerApp 'br/public:avm/res/network/network-security-group:0.5.2' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parAcaNsgName
    location: parLocation
  }
}

// Route Table for APIM Subnet (prevents forced tunneling)
module modApimRouteTable 'br/public:avm/res/network/route-table:0.5.0' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parApimRouteName
    location: parLocation
    routes: [
      {
        name: 'apim-management-endpoint'
        properties: {
          addressPrefix: 'ApiManagement'
          nextHopType: 'Internet'
        }
      }
    ]
  }
}


// Public IP configurations for loop deployment
var varPublicIpConfigs = [
  {
    key: 'appgw'
    name: parAppGwPublicIpName
    dnsLabel: parAppGatewayDnsName
  }
  {
    key: 'apim'
    name: parApimPublicIpName
    dnsLabel: parApimDnsName
  }
]
  // MARK: - Public IP Addresses
module modPublicIps 'br/public:avm/res/network/public-ip-address:0.8.0' = [for config in varPublicIpConfigs: {
  scope: resourceGroup(parHubResourceGroupName)
  name: 'pip-${config.key}'
  params: {
    name: config.name
    location: parLocation
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    zones: []
    dnsSettings: {
      domainNameLabel: config.dnsLabel
    }
  }
}]

// Virtual Network for Hub with Subnets
module modHubVirtualNetwork 'br/public:avm/res/network/virtual-network:0.7.1' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubVirtualNetworkName
    location: parLocation
    addressPrefixes: [
      parHubVirtualNetworkAddressPrefix
    ]
    subnets: [
      {
        name: parApimSubnetName
        addressPrefix: parApimSubnetAddressPrefix
        networkSecurityGroupResourceId: modNsgApim.outputs.resourceId
        routeTableResourceId: modApimRouteTable.outputs.resourceId
        serviceEndpoints: [
          'Microsoft.Storage'
          'Microsoft.Sql'
          'Microsoft.EventHub'
          'Microsoft.KeyVault'
          'Microsoft.ServiceBus'
          'Microsoft.AzureActiveDirectory'
        ]
      }
      {
        name: parAppGwSubnetName
        addressPrefix: parAppGatewaySubnetAddressPrefix
      }
      {
        name: parPeSubnetName
        addressPrefix: parPeSubnetAddressPrefix
      }
    ]
  }
}

// MARK: - Virtual Network for Spoke with Peering
module modSpokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.7.1' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parSpokeVirtualNetworkName
    addressPrefixes: [
      parSpokeVirtualNetworkAddressPrefix
    ]
    subnets: [
      {
        name: parAcaSubnetName
        addressPrefix: parAcaSubnetAddressPrefix
        networkSecurityGroupResourceId: modNsgContainerApp.outputs.resourceId
        serviceEndpoints: [
          'Microsoft.Storage'
        ]
        delegation: 'Microsoft.App/environments'
      }
    ]
  }
}

// MARK: - Vnet Hub Peering
module modVnetHubPeering'./network_hub_peering.bicep' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parSpokeVnetId: modSpokeVirtualNetwork.outputs.resourceId
  }
  dependsOn: [
    modHubVirtualNetwork
  ]
}

// MARK: - Vnet Spoke Peering
module modVnetSpokePeering'./network_spoke_peering.bicep' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    parSpokeVirtualNetworkName: parSpokeVirtualNetworkName
    parHubVnetId: modHubVirtualNetwork.outputs.resourceId
  }
  dependsOn: [
    modSpokeVirtualNetwork
  ]
}



// Private DNS Zone for APIM (Internal mode) - A record will be created after APIM deployment
module modApimPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.0' = {
  scope: resourceGroup(parHubResourceGroupName)
  name: 'apimPrivateDnsZone'
  params: {
    name: 'azure-api.net'
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: modHubVirtualNetwork.outputs.resourceId
        registrationEnabled: false
      }
      {
        virtualNetworkResourceId: resourceId(subscription().subscriptionId, parSpokeResourceGroupName, 'Microsoft.Network/virtualNetworks', parSpokeVirtualNetworkName)
        registrationEnabled: false
      }
    ]
  }
}


var varFoundryDnsZones = [
  'privatelink.cognitiveservices.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.services.ai.azure.com'
]
module modFoundryPrivateDnsZones 'br/public:avm/res/network/private-dns-zone:0.8.0' = [for zone in varFoundryDnsZones: {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: 'foundryDnsZone-${replace(zone, '.', '-')}'
  params: {
    name: zone
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: modSpokeVirtualNetwork.outputs.resourceId
        registrationEnabled: false
      }
    ]
  }
}]

// Private DNS Zone for PostgreSQL Flexible Server
module modPostgresDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: 'postgresDnsZone'
  params: {
    name: 'privatelink.postgres.database.azure.com'
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: modSpokeVirtualNetwork.outputs.resourceId
        registrationEnabled: false
      }
    ]
  }
}

//===== STORAGE REQUIRES NETWORK =============

// MARK: - Storage Account
module modStorageAccount 'br/public:avm/res/storage/storage-account:0.29.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parStorageAccountName
    location: parLocation
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    allowBlobPublicAccess: false
    managedIdentities: {
      systemAssigned: true
    }
    fileServices: {
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
      shares: [
        {
          name: parShareName
          shareQuota: 100
          enabledProtocols: 'SMB'
          accessTier: 'TransactionOptimized'
        }
      ]
     }
         networkAcls: {
       virtualNetworkRules:[
          {
            id: modSpokeVirtualNetwork.outputs.subnetResourceIds[0]  //subnet id for aca subnet
            ignoreMissingVnetServiceEndpoint: false
          }
       ]
    }
    secretsExportConfiguration: {
      keyVaultResourceId: modSpokeKeyVault.outputs.resourceId
      accessKey1Name: 'accessKey1'
      accessKey2Name: 'accessKey2'
      connectionString1Name: 'connectionString1'
      connectionString2Name: 'connectionString2'
    }
  }
  dependsOn: [modSpokeResourceGroup]
}
