targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== MARK: Parameters ==========
param parAppGwPublicIpName string
param parHubResourceGroupName string
param parAppRegistrationName string


// ========== MARK: Existing Resources ==========
resource appGwPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parAppGwPublicIpName
  }


// ========== MARK: Variables ==========
var varAppGwPublicIpDns = appGwPublicIp.properties.dnsSettings.fqdn



// MARK: - Entra ID App Registration
resource resEntraIdApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: parAppRegistrationName
  uniqueName: parAppRegistrationName
  signInAudience: 'AzureADMyOrg'
  isFallbackPublicClient: true
  groupMembershipClaims: 'SecurityGroup'
  identifierUris: ['api://${parAppRegistrationName}']
  owners: {
    relationships: [
      deployer().objectId
    ]
  }
  appRoles: [
    {
      allowedMemberTypes: ['User']
      description: 'Administrator role with full access to Open WebUI'
      displayName: 'Administrator'
      id: guid(parAppRegistrationName, 'admin')
      isEnabled: true
      value: 'admin'
    }
    {
      allowedMemberTypes: ['User']
      description: 'Standard user role with default permissions'
      displayName: 'User'
      id: guid(parAppRegistrationName, 'user')
      isEnabled: true
      value: 'user'
    }
  ]
  optionalClaims: {
    idToken: [
      {
        name: 'groups'
        essential: false
        additionalProperties: []
      }
      {
        name: 'ipaddr'
        essential: false
        additionalProperties: []
      }
    ]
    accessToken: [
      {
        name: 'groups'
        essential: false
        additionalProperties: []
      }
      {
        name: 'ipaddr'
        essential: false
        additionalProperties: []
      }
    ]
  }
  api: {
    requestedAccessTokenVersion: 2
    oauth2PermissionScopes: [
      {
        adminConsentDescription: 'Allow the application to access Open WebUI on behalf of the signed-in user'
        adminConsentDisplayName: 'Access Open WebUI'
        id: guid(parAppRegistrationName, 'user_impersonation')
        isEnabled: true
        type: 'User'
        userConsentDescription: 'Allow the application to access Open WebUI on your behalf'
        userConsentDisplayName: 'Access Open WebUI'
        value: 'user_impersonation'
      }
    ]
  }
  web: {
    redirectUris: [
      'https://${varAppGwPublicIpDns}/oauth/oidc/callback'
    ]
    implicitGrantSettings: {
      enableIdTokenIssuance: true
      enableAccessTokenIssuance: true
    }
  }
  publicClient: {
    redirectUris: [
      'https://${varAppGwPublicIpDns}/oauth/oidc/callback'
    ]
  }
  requiredResourceAccess: [
    {
      resourceAppId: '00000003-0000-0000-c000-000000000000' // Microsoft Graph
      resourceAccess: [
        {
          id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d' // User.Read (Delegated)
          type: 'Scope'
        }
        {
          id: 'bc024368-1153-4739-b217-4326f2e966d0' // GroupMember.Read.All (Delegated)
          type: 'Scope'
        }
        {
          id: 'c72d93c1-a342-4d87-90ff-27b3e0e79e0c' // ProfilePhoto.Read.All (Delegated)
          type: 'Scope'
        }
      ]
    }
  ]
}

// MARK: - Entra ID Service Principal
resource resEntraIdServicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: resEntraIdApp.appId
  appRoleAssignmentRequired: true
}
