targetScope = 'subscription'

// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== MARK: Parameters ==========
param parAppGatewayName string
param parAppGatewayPublicIpName string
param parAppGatewaySku string
param parAppGwSubnetName string
param parContainerName string
param parHubEnvManagedId string
param parHubKeyVaultName string
param parHubResourceGroupName string
param parHubVirtualNetworkName string
param parLocation string
param parSpokeResourceGroupName string
param parSslCertificateName string

//FOR TRUSTING OUTSIDE DOMAIN
//param parCustomDomain string
//param parSpokeKeyVaultName string
//aram parTrustedRootCertificateSecretName string
//param parHubKeyVaultUri string


resource hubKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: parHubKeyVaultName
  scope: resourceGroup(parHubResourceGroupName)
}

var hubKeyVaultUri = hubKeyVault.properties.vaultUri

resource containerApp 'Microsoft.App/containerApps@2024-03-01' existing = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: parContainerName
}


resource hubEnvManagedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubEnvManagedId
}

resource appGwPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parAppGatewayPublicIpName
  }


resource hubVirtualNet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubVirtualNetworkName
}

resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  name: parAppGwSubnetName
  parent: hubVirtualNet
}


// ========== MARK: Variables ==========
var appGwPublicIpId  = appGwPublicIp.id
var appGwFQDN = appGwPublicIp.properties.dnsSettings.fqdn
var parAppGatewaySubnetId = appGwSubnet.id
var parContainerAppFqdn = containerApp.properties.configuration.ingress.fqdn
var parSslCertificateUrl = '${hubKeyVaultUri}secrets/${parSslCertificateName}'

// Application Gateway using AVM module
module modAppGateway 'br/public:avm/res/network/application-gateway:0.6.0' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: parAppGatewayName
    location: parLocation
    sku: parAppGatewaySku
    capacity: 1
    zones: []
    managedIdentities: { //!empty(parCustomDomain) ? 
      userAssignedResourceIds: [
        hubEnvManagedId.id
      ]
    } 
    /*
    trustedRootCertificates: !empty(parCustomDomain) ? [
      {
        name: parTrustedRootCertificateSecretName
        properties: {
          keyVaultSecretId: '${parHubKeyVaultUri}secrets/${parTrustedRootCertificateSecretName}'
        }
      }
    ] : []
     */
    
    sslCertificates: [  // (!empty(parCustomDomain) && !empty(parHubKeyVaultName)) ?
      {
        name: parSslCertificateName
        properties: {
          keyVaultSecretId: parSslCertificateUrl
        }
      }
    ] 
    gatewayIPConfigurations: [
      {
        name: 'appgw-ip-config'
        properties: {
          subnet: {
            id: parAppGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appgw-frontend-ip'
        properties: {
          publicIPAddress: {
            id: appGwPublicIpId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port-443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'containerapp-backend-pool'
        properties: {
          backendAddresses:[
            {
              fqdn: parContainerAppFqdn
            }
          ] 
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'containerapp-backend-settings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Enabled'
          pickHostNameFromBackendAddress: true
          //hostName: !empty(parCustomDomain) ? parCustomDomain : null
          // Bump timeout to tolerate slower cold starts and long requests (default is 30s)
          requestTimeout: 120
          /* no custom domain for now
          trustedRootCertificates: !empty(parCustomDomain) ? [
            {
              id: resourceId(subscription().subscriptionId, parResourceGroupName, 'Microsoft.Network/applicationGateways/trustedRootCertificates', parAppGatewayName, parTrustedRootCertificateSecretName)
            }
          ] : null
           */
          probe: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/probes', parAppGatewayName, 'containerapp-health-probe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'containerapp-health-probe'
        properties: {
          protocol: 'Https'
          // Use a lightweight API endpoint and give more time for cold starts
          path: '/api/version'
          interval: 30
          timeout: 60
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: ['200-399']
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'containerapp-http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', parAppGatewayName, 'appgw-frontend-ip')
          }
          frontendPort: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/frontendPorts', parAppGatewayName, 'port-80')
          }
          protocol: 'Http'
          hostName: appGwFQDN
        }
      }
      {
        name: 'containerapp-https-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', parAppGatewayName, 'appgw-frontend-ip')
          }
          frontendPort: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/frontendPorts', parAppGatewayName, 'port-443')
          }
          protocol: 'Https'
          hostName: appGwFQDN
          sslCertificate: { //(!empty(parCustomDomain) && !empty(parSpokeKeyVaultName)) ? {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/sslCertificates', parAppGatewayName, parSslCertificateName)
          } 
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'containerapp-routing-rule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/httpListeners', parAppGatewayName, 'containerapp-http-listener')
          }
          redirectConfiguration: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/redirectConfigurations', parAppGatewayName, 'http-to-https-redirect')
          }
        }
      }
      {
        name: 'containerapp-https-routing-rule'
        properties: {
          ruleType: 'Basic'
          priority: 101
          httpListener: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/httpListeners', parAppGatewayName, 'containerapp-https-listener')
          }
          backendAddressPool: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/backendAddressPools', parAppGatewayName, 'containerapp-backend-pool')
          }
          backendHttpSettings: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parAppGatewayName, 'containerapp-backend-settings')
          }
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'http-to-https-redirect'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/applicationGateways/httpListeners', parAppGatewayName, 'containerapp-https-listener')
          }
          includePath: true
          includeQueryString: true
        }
      }
    ]
  }
}

// Outputs
output resourceId string = modAppGateway.outputs.resourceId
output name string = modAppGateway.outputs.name
