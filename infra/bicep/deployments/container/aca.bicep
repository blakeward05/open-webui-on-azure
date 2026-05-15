targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// MARK:========== Parameters ==========
param parContainerAppEnvName string
param parContainerAppScaleSettings object
param parContainerName string
param parKeyVaultUserIdRole string
param parLocation string
param parShareName string
param parSpokeEnvManagedId string
param parSpokeKeyVaultName string
param parSpokeResourceGroupName string
param parStorageAccountName string
param parSubscriptionId string
param parVolumeMount string


// ========== MARK: Existing Resource ==========
var varSpokeKeyVaultResourceId = resourceId(parSubscriptionId, parSpokeResourceGroupName, 'Microsoft.KeyVault/vaults', parSpokeKeyVaultName)

resource spokeKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: parSpokeKeyVaultName
  scope: resourceGroup(parSpokeResourceGroupName)
}

var spokeKeyVaultUri = spokeKeyVault.properties.vaultUri

resource spokeEnvManagedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: parSpokeEnvManagedId
  scope: resourceGroup(parSpokeResourceGroupName)
}


// MARK: - Container App Environment
module modContainerAppEnv 'br/public:avm/res/app/managed-environment:0.11.3' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parContainerAppEnvName
    location: parLocation
    //appInsightsConnectionString: modAppInsights.outputs.connectionString
    publicNetworkAccess: 'Disabled'
    zoneRedundant: false
    storages: [
      {
        kind: 'SMB'
        accessMode: 'ReadWrite'
        shareName: parShareName
        storageAccountName: parStorageAccountName
      }
    ]
    internal: false
    //REMOVING REFERENCE TO SUBNET HERE ON APP ENVIRONMENT
    //infrastructureSubnetResourceId: modVirtualNetwork.outputs.subnetResourceIds[0]
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        spokeEnvManagedId.id
      ]
    }
    /*
    // az keyvault certificate import --vault-name <kv-name> --name <cert-name> --file file.pfx
    certificate: {
      name: parCertificateName
      certificateKeyVaultProperties: {
        identityResourceId: modEnvIdentity.outputs.resourceId
        keyVaultUrl: '${modKeyVault.outputs.uri}secrets/${parCertificateName}'
      }
    }
      */
  }
}


// MARK: - Container App
module modContainerApp 'br/public:avm/res/app/container-app:0.19.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parContainerName
    ingressTargetPort: 8080
    stickySessionsAffinity: 'sticky'
    /*
    //IGNORING SECURITY AND NETWORKING FOR NOW
    //ipSecurityRestrictions: !empty(parContainerAppAllowedIpAddresses) ? varIpSecurityRestrictions : []
    customDomains: [
      {
        name: parCustomDomain
        certificateId: '${modContainerAppEnv.outputs.resourceId}/certificates/${parCertificateName}'
        bindingType: 'SniEnabled'
      }
    ]
      */
    containers: [
      {
        name: parContainerName
        image: 'ghcr.io/open-webui/open-webui:main'
        resources: {
          cpu: json('0.5')
          memory: '1Gi'
        }
        env: [
          // see https://docs.openwebui.com/getting-started/env-configuration/
          {
            name: 'WEBUI_URL'
            value: ''
          }
            {
            name: 'ENABLE_LOGIN_FORM'
            value: 'true'
          }
           {
            name: 'ENV'
            value: 'prod'
          }
          {
            name: 'DATA_DIR'
            value: '/app/data'
          }
          {
            name: 'WEBUI_NAME'
            value: 'Open WebUI'
          }
          {
            name: 'ENABLE_SIGNUP'
            value: 'true' 
          }
          /*
          {
            name: 'ENABLE_OAUTH_SIGNUP'
            value: 'true'
          }
          {
            name: 'ENABLE_OAUTH_PERSISTENT_CONFIG'
            value: 'false'
          }
          {
            name: 'OAUTH_CLIENT_ID'
            value: resEntraIdApp.appId
          }
          {
            name: 'OAUTH_CODE_CHALLENGE_METHOD'
            value: 'S256'
          }
          {
            name: 'OAUTH_PROVIDER_NAME'
            value: 'Microsoft Entra ID'
          }
          {
            name: 'OAUTH_SCOPES'
            value: 'openid email profile api://${varAppRegistrationName}/user_impersonation User.Read GroupMember.Read.All ProfilePhoto.Read.All'
          }
          {
            name: 'OPENID_PROVIDER_URL'
            value: '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0/.well-known/openid-configuration'
          }
          {
            name: 'OAUTH_EMAIL_CLAIM'
            value: 'email'
          }
          {
            name: 'OAUTH_USERNAME_CLAIM'
            value: 'name'
          }
          {
            name: 'OPENAI_API_BASE_URL'
            value: 'https://${parApimName}.azure-api.net/openai/v1'
          }
            {
            name: 'OAUTH_ROLES_CLAIM'
            value: 'roles'
          }
          {
            name: 'OAUTH_ALLOWED_ROLES'
            value: 'user,admin'
          }
          {
            name: 'OAUTH_ADMIN_ROLES'
            value: 'admin'
          }
          {
            name: 'ENABLE_OAUTH_GROUP_MANAGEMENT'
            value: 'true'
          }
          {
            name: 'ENABLE_OAUTH_GROUP_CREATION'
            value: 'true'
          }
          {
            name: 'OAUTH_GROUPS_CLAIM'
            value: 'groups'
          }
          */
          {
            name: 'DEFAULT_USER_ROLE'
            value: 'user'
          }
          {
            name: 'ENABLE_ADMIN_CHAT_ACCESS'
            value: 'true'
          }
          {
            name: 'ENABLE_ADMIN_EXPORT'
            value: 'true'
          }
          {
            name: 'WEBUI_SESSION_COOKIE_SAME_SITE'
            value: 'lax' 
          }
          {
            name: 'WEBUI_SESSION_COOKIE_SECURE'
            value: 'true'
          }
          {
            name: 'ENABLE_COMMUNITY_SHARING'
            value: 'false'
          }
          {
            name: 'ENABLE_MESSAGE_RATING'
            value: 'true'
          }
          {
            name: 'GLOBAL_LOG_LEVEL'
            value: 'INFO'
          }
          {
            name: 'ENABLE_OAUTH_ROLE_MANAGEMENT'
            value: 'true'
          }
          {
            name: 'AIOHTTP_CLIENT_TIMEOUT'
            value: '300'
          }
          {
            name: 'DATABASE_URL'
            secretRef: 'database-url'
          }
        ]
        volumeMounts: [
          {
            volumeName: parVolumeMount
            mountPath: '/app/backend/data'
          }
        ]
        // Health probes commented out for initial deployment due to slow first boot
        // After the initial deployment completes, these can be uncommented to improve reliability
        // probes: [
        //   {
        //     type: 'startup'
        //     httpGet: {
        //       path: '/health'
        //       port: 8080
        //     }
        //     initialDelaySeconds: 5
        //     periodSeconds: 5
        //     failureThreshold: 60
        //   }
        //   {
        //     type: 'liveness'
        //     httpGet: {
        //       path: '/health'
        //       port: 8080
        //     }
        //     initialDelaySeconds: 30
        //     periodSeconds: 10
        //     failureThreshold: 3
        //   }
        //   {
        //     type: 'readiness'
        //     httpGet: {
        //       path: '/health'
        //       port: 8080
        //     }
        //     initialDelaySeconds: 10
        //     periodSeconds: 5
        //     failureThreshold: 3
        //   }
        // ]
      }
    ]
    secrets: [
      {
        name: 'database-url'
        keyVaultUrl: '${spokeKeyVaultUri}secrets/postgres-connection-string'
        identity: 'System'
      }
    ]
    volumes: [
      {
        name: parVolumeMount
        storageName: parShareName
        storageType: 'AzureFile'
        mountOptions: 'nobrl,noperm,mfsymlinks,cache=strict'
      }
    ]
    scaleSettings: parContainerAppScaleSettings
    ingressAllowInsecure: false
    environmentResourceId: modContainerAppEnv.outputs.resourceId
    location: parLocation
    managedIdentities: {
      systemAssigned: true
    }
  }
}

// MARK: - RBAC for Container App
module modContainerAppKeyVaultRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    principalId: modContainerApp.outputs.systemAssignedMIPrincipalId!
    roleName: 'Key Vault Secrets User'
    resourceId: varSpokeKeyVaultResourceId
    roleDefinitionId: parKeyVaultUserIdRole
    principalType: 'ServicePrincipal'
  }
}
