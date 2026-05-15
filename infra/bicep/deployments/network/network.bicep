// Networking Module
targetScope = 'subscription'



// ========== MARK: Parameters ==========
param parLocation string
param parHubResourceGroupName string
param parSpokeResourceGroupName string
param parHubVirtualNetworkName string
param parSpokeVirtualNetworkName string
param parHubVirtualNetworkAddressPrefix string
param parSpokeVirtualNetworkAddressPrefix string
param parApimSubnetName string
param parAppGwSubnetName string
param parPeSubnetName string
param parAcaSubnetName string
param parAcaSubnetAddressPrefix string
param parApimSubnetAddressPrefix string
param parAppGatewaySubnetAddressPrefix string
param parPeSubnetAddressPrefix string
param parContainerAppEnvName string
param parContainerName string
param parAppGatewayDnsName string
param parAppGwPublicIpName string
param parApimPublicIpName string
param parApimDnsName string


resource containerAppEnv 'Microsoft.App/managedEnvironments@2026-01-01' existing = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: parContainerAppEnvName
}


// ========== MARK: Variables ==========
var parContainerAppEnvDefaultDomain = containerAppEnv.properties.defaultDomain
var parContainerAppStaticIp = containerAppEnv.properties.staticIp
//var varNsgRules = loadJsonContent('../../../shared/nsg-rules.json')


/* removing NSG rules
// NSG for APIM Subnet
module modNsgApim 'br/public:avm/res/network/network-security-group:0.5.2' = {
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: '${parNamePrefix}-apim-nsg'
    location: parLocation
    securityRules: parNsgRules
  }
}

// MARK: - Network Security Group
module modNsgContainerApp 'br/public:avm/res/network/network-security-group:0.5.2' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: '${parNamePrefix}-aca-nsg'
    location: parLocation
  }
  dependsOn: [modResourceGroup]
}
  */

/*
// Route Table for APIM Subnet (prevents forced tunneling)
module modApimRouteTable 'br/public:avm/res/network/route-table:0.5.0' = {
  params: {
    name: '${parNamePrefix}-apim-rt'
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
  */


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
        //networkSecurityGroupResourceId: modNsgApim.outputs.resourceId
        //routeTableResourceId: modApimRouteTable.outputs.resourceId
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
    /* peering done in second step
    peerings: !empty(parSpokeVirtualNetworkName) ? [
      {
        remoteVirtualNetworkResourceId: resourceId(subscription().subscriptionId, parSpokeResourceGroupName, 'Microsoft.Network/virtualNetworks', parSpokeVirtualNetworkName)
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false
        doNotVerifyRemoteGateways: true
      }
       
    ] : []
      */
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
        //networkSecurityGroupResourceId: modNsgContainerApp.outputs.resourceId
        serviceEndpoints: [
          'Microsoft.Storage'
        ]
        delegation: 'Microsoft.App/environments'
      }
    ]
     /* peering done in second step
    // Spoke to Hub VNet peering
    peerings: !empty(parHubVirtualNetworkName) ? [
      {
        remoteVirtualNetworkResourceId: resourceId(subscription().subscriptionId, parHubResourceGroupName, 'Microsoft.Network/virtualNetworks', parHubVirtualNetworkName)
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false
      }
    ] : []
     */
  }
}



// Private DNS Zone for Container App
module modPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: 'privateDnsZone'
  params: {
    name: parContainerAppEnvDefaultDomain
    location: 'global'
    a: [
      {
        name: parContainerName
        ttl: 3600
        aRecords: [
          { ipv4Address: parContainerAppStaticIp }
        ]
      }
    ]
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: modSpokeVirtualNetwork.outputs.resourceId
        registrationEnabled: false
      }
    ]
  }
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

