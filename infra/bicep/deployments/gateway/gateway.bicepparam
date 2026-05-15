using 'gateway.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parLocation = config.location
param parAppGatewayName = 'appgw-${parNameSuffix}-hub'
param parAppGatewaySku = 'Standard_v2'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parHubKeyVaultName = 'kv-${parNameSuffix}-hub'
param parSpokeResourceGroupName = 'rg-${parNameSuffix}-spoke'
param parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'
param parAppGatewayPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
//param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parContainerName = '${parNameSuffix}-aca'
param parSslCertificateName = config.sslCertificateSecretName
param parHubEnvManagedId = 'umi-${parNameSuffix}-hub'
