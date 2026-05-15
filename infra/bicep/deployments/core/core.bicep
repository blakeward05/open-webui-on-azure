//creates resource groups for hub and spoke, key vaults for hub and spoke
//storage account for countainer to mount

targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== Type Imports ==========
import { TagsType } from '../../shared/types.bicep'


// ========== MARK: Parameters ==========
param parHubAppInsightsName string
param parHubEnvManagedId string
param parHubKeyVaultName string
param parHubLogAnalyticsWorkspaceName string
param parHubResourceGroupName string
param parKeyVaultUserIdRole string
param parLocation string
param parShareName  string
param parSpokeAppInsightsName string
param parSpokeEnvManagedId string
param parSpokeKeyVaultName string
param parSpokeLogAnalyticsWorkspaceName string
param parSpokeResourceGroupName string
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

// MARK: - Hub Log Analytics Workspace
module modHubLogAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.13.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
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
    modSpokeResourceGroup
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
  dependsOn: [modHubResourceGroup]
}

// Managed Identity for Application Gateway
module modAppGatewayIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' =  {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parHubEnvManagedId
    location: parLocation
  }
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
