using 'gateway.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix

param parAppGatewayName = 'appgw-${parNameSuffix}-hub'
param parAppGatewayPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
param parAppGatewaySku = 'Standard_v2'
param parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'
param parContainerName = '${parNameSuffix}-aca'
param parHubEnvManagedId = 'umi-${parNameSuffix}-hub'
param parHubKeyVaultName = 'kv-${parNameSuffix}-hub'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parLocation = config.location
param parSpokeResourceGroupName = 'rg-${parNameSuffix}-spoke'
param parSslCertificateName = config.sslCertificateSecretName

