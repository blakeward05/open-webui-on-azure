targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'



var config = loadJsonContent('./shared/env_vars.json')

var parAppName string = config.nameSuffix
/*
//-------------TEST NETWORK-------------
var parHubResourceGroupName = 'rg-${parAppName}-hub'
var parHubVirtualNetworkName = 'vnet-${parAppName}-hub'
var parAppGwSubnetName = 'appgw-${parAppName}-hub-subnet'


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
var parSpokeResourceGroupName = 'rg-${parAppName}-spoke'
var parFoundryName = 'foundry-${parAppName}'

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: parFoundryName
}

output inferenceEndpoint string = aiFoundry.properties.endpoint
*/
//-------------TEST APP REG-------------
/*
var parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'

resource appRegistration 'Microsoft.Graph/applications@v1.0' existing = {
  uniqueName: parAppRegistrationName
}

output regId string = appRegistration.id
*/
//-------------IP ADDRESS------------
/*
var parHubResourceGroupName = 'rg-${parAppName}-hub'
var parAppGatewayPublicIpName = 'pip-appgw-${parAppName}-hub'

resource appGwPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' existing = {
  scope: resourceGroup(parHubResourceGroupName)
  name: parAppGatewayPublicIpName
  }

output fqdn string = appGwPublicIp.properties.dnsSettings.fqdn
*/

param objectToTest object = {
  core: 1
  postgres: 0
  container: 0
  foundry: 0
  network: 0
  entra: 0
  gateway: 0
  apim: 0

}

output bar bool = objectToTest.core == 0
