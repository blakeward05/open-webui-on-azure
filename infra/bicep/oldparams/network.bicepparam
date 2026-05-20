using 'network.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parAppName string = config.nameSuffix

param parAcaNsgName = 'nsg-${parAppName}-aca'
param parAcaSubnetAddressPrefix = '10.0.4.0/23'
param parAcaSubnetName = 'aca-${parAppName}-spoke-subnet'
param parApimDnsName = 'apim-dns-${parAppName}'
param parApimNsgName = 'nsg-${parAppName}-apim'
param parApimPublicIpName = 'pip-apim-${parAppName}-hub'
param parApimRouteName = 'rt-${parAppName}-apim'
param parApimSubnetAddressPrefix = '10.0.0.0/28'
param parApimSubnetName = 'apim-${parAppName}-hub-subnet'
param parAppGatewayDnsName = 'appgw-dns-${parAppName}'
param parAppGatewaySubnetAddressPrefix = '10.0.0.64/26'
param parAppGwPublicIpName = 'pip-appgw-${parAppName}-hub'
param parAppGwSubnetName = 'appgw-${parAppName}-hub-subnet'
param parContainerAppEnvName = replace('${parAppName}-aca-env', '-', '')
param parContainerName = '${parAppName}-aca'
param parHubResourceGroupName = 'rg-${parAppName}-hub'
param parHubVirtualNetworkAddressPrefix = '10.0.0.0/24'
param parHubVirtualNetworkName = 'vnet-${parAppName}-hub'
param parLocation = config.location
param parPeSubnetAddressPrefix = '10.0.0.128/28'
param parPeSubnetName = 'pe-${parAppName}-hub-subnet'
param parSpokeResourceGroupName =  'rg-${parAppName}-spoke'
param parSpokeVirtualNetworkAddressPrefix = '10.0.4.0/22'
param parSpokeVirtualNetworkName = 'vnet-${parAppName}-spoke'
