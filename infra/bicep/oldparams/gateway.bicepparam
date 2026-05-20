using 'gateway.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parAppName string = config.nameSuffix

param parAppGatewayName = 'appgw-${parAppName}-hub'
param parAppGatewayPublicIpName = 'pip-appgw-${parAppName}-hub'
param parAppGatewaySku = 'Standard_v2'
param parAppGwSubnetName = 'appgw-${parAppName}-hub-subnet'
param parContainerName = '${parAppName}-aca'
param parHubEnvManagedId = 'umi-${parAppName}-hub'
param parHubKeyVaultName = 'kv-${parAppName}-hub'
param parHubResourceGroupName = 'rg-${parAppName}-hub'
param parHubVirtualNetworkName = 'vnet-${parAppName}-hub'
param parLocation = config.location
param parSpokeResourceGroupName = 'rg-${parAppName}-spoke'
param parSslCertificateName = config.sslCertificateSecretName

