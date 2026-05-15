targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'



var config = loadJsonContent('./infra/bicep/shared/env_vars.json')

var parNameSuffix string = config.nameSuffix
/*
//-------------TEST NETWORK-------------
var parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
var parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
var parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'


resource hubVirtualNet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parHubVirtualNetworkName
}

resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  name: parAppGwSubnetName
  parent: hubVirtualNet
}

output appGwSubnetid string = appGwSubnet.id
*/

//-------------TEST FOUNDRY-------------
/*
var parSpokeResourceGroupName = 'rg-${parNameSuffix}-spoke'
var parFoundryName = 'foundry-${parNameSuffix}'

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: parFoundryName
}

output inferenceEndpoint string = aiFoundry.properties.endpoint
*/
//-------------TEST APP REG-------------

var parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'

resource appRegistration 'Microsoft.Graph/applications@v1.0' existing = {
  uniqueName: parAppRegistrationName
}

output regId string = appRegistration.id

//-------------IP ADDRESS------------
/*
var parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
var parAppGatewayPublicIpName = 'pip-appgw-${parNameSuffix}-hub'

resource appGwPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parAppGatewayPublicIpName
  }

output fqdn string = appGwPublicIp.properties.dnsSettings.fqdn
*/
