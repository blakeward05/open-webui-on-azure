using 'main_one.bicep'

var config = loadJsonContent('./shared/env_vars.json')

// Change values as required for your setup/demo/poc

var parNameSuffix string = config.nameSuffix


// ========== MARK: Parameters ==========
param parAcaNsgName = 'nsg-${parNameSuffix}-aca'
param parAcaSubnetAddressPrefix = '10.0.4.0/23'
param parAcaSubnetName = 'aca-${parNameSuffix}-spoke-subnet'
param parApimDnsName = 'apim-dns-${parNameSuffix}'
param parApimName = 'apim-${parNameSuffix}-hub'
param parApimNsgName = 'nsg-${parNameSuffix}-apim'
param parApimPublicIpName = 'pip-apim-${parNameSuffix}-hub'
param parApimRouteName = 'rt-${parNameSuffix}-apim'
param parApimSku = config.apimSku
param parApimSubnetAddressPrefix = '10.0.0.0/28'
param parApimSubnetName = 'apim-${parNameSuffix}-hub-subnet'
param parAppGatewayDnsName = 'appgw-dns-${parNameSuffix}'
param parAppGatewayName = 'appgw-${parNameSuffix}-hub'
param parAppGatewayPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
param parAppGatewaySku = 'Standard_v2'
param parAppGatewaySubnetAddressPrefix = '10.0.0.64/26'
param parAppGwPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
param parAppGwSubnetName = 'appgw-${parNameSuffix}-hub-subnet'
param parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'
param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parContainerAppScaleSettings = {
  minReplicas: 1
  maxReplicas: 1
}
param parContainerName = '${parNameSuffix}-aca'
param parFoundryEndpoint = 'https://${parFoundryName}.services.ai.azure.com'
param parFoundryName = 'foundry-${parNameSuffix}'
param parFoundrySku = 'S0'
param parHubAppInsightsName = 'apins-${parNameSuffix}-hub'
param parHubEnvManagedId = 'umi-${parNameSuffix}-hub'
param parHubKeyVaultName = 'kv-${parNameSuffix}-hub'
param parHubLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-hub'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkAddressPrefix = '10.0.0.0/24'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parLocation = config.location
param parMonitoringMetricsRole = config.roleDefinitions.monitoringMetricsPublisher
param parPeSubnetAddressPrefix = '10.0.0.128/28'
param parPeSubnetName = 'pe-${parNameSuffix}-hub-subnet'
param parPostgresServerName = 'pgsql-${parNameSuffix}'
param parPublisherEmail = config.publisherEmail
param parPublisherName = config.publisherName
param parShareName = '${parNameSuffix}-share'
param parSpokeAppInsightsName = 'apins-${parNameSuffix}-spoke'
param parSpokeEnvManagedId = 'umi-${parNameSuffix}-spoke'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'
param parSpokeLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-spoke'
param parSpokeResourceGroupName =  'rg-${parNameSuffix}-spoke'
param parSpokeVirtualNetworkAddressPrefix = '10.0.4.0/22'
param parSpokeVirtualNetworkName = 'vnet-${parNameSuffix}-spoke'
param parSslCertificateName = config.sslCertificateSecretName
param parStorageAccountName = replace('${parNameSuffix}sa', '-', '')
param parSubscriptionId = config.subscriptionId
param parVolumeMount = '${parShareName}-volume'


