using 'network.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parLocation = config.location
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parSpokeResourceGroupName =  'rg-${parNameSuffix}-spoke'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parSpokeVirtualNetworkName = 'vnet-${parNameSuffix}-spoke'
param parApimSubnetName = 'apim-${parNameSuffix}-hub-subnet'
param parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'
param parPeSubnetName = 'pe-${parNameSuffix}-hub-subnet'
param parAcaSubnetName = 'aca-${parNameSuffix}-spoke-subnet'
param parHubVirtualNetworkAddressPrefix = '10.0.0.0/24'
param parSpokeVirtualNetworkAddressPrefix = '10.0.4.0/22'
param parApimSubnetAddressPrefix = '10.0.0.0/28'
param parAppGatewaySubnetAddressPrefix = '10.0.0.64/26'
param parPeSubnetAddressPrefix = '10.0.0.128/28'
param parAcaSubnetAddressPrefix = '10.0.4.0/23'
param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parContainerName = '${parNameSuffix}-aca'
param parAppGatewayDnsName = 'appgw-dns-${parNameSuffix}'
param parAppGwPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
param parApimPublicIpName = 'pip-apim-${parNameSuffix}-hub'
param parApimDnsName = 'apim-dns-${parNameSuffix}'
