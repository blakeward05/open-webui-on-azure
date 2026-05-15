using 'network.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix

param parAcaNsgName = 'nsg-${parNameSuffix}-aca'
param parAcaSubnetAddressPrefix = '10.0.4.0/23'
param parAcaSubnetName = 'aca-${parNameSuffix}-spoke-subnet'
param parApimDnsName = 'apim-dns-${parNameSuffix}'
param parApimNsgName = 'nsg-${parNameSuffix}-apim'
param parApimPublicIpName = 'pip-apim-${parNameSuffix}-hub'
param parApimRouteName = 'rt-${parNameSuffix}-apim'
param parApimSubnetAddressPrefix = '10.0.0.0/28'
param parApimSubnetName = 'apim-${parNameSuffix}-hub-subnet'
param parAppGatewayDnsName = 'appgw-dns-${parNameSuffix}'
param parAppGatewaySubnetAddressPrefix = '10.0.0.64/26'
param parAppGwPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
param parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'
param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parContainerName = '${parNameSuffix}-aca'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkAddressPrefix = '10.0.0.0/24'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parLocation = config.location
param parPeSubnetAddressPrefix = '10.0.0.128/28'
param parPeSubnetName = 'pe-${parNameSuffix}-hub-subnet'
param parSpokeResourceGroupName =  'rg-${parNameSuffix}-spoke'
param parSpokeVirtualNetworkAddressPrefix = '10.0.4.0/22'
param parSpokeVirtualNetworkName = 'vnet-${parNameSuffix}-spoke'
