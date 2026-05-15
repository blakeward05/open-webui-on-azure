using 'apim.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
param parApimName = 'apim-${parNameSuffix}-hub'
param parApimPublicIpName = 'pip-apim-${parNameSuffix}-hub'
param parApimSku = config.apimSku
param parApimSubnetName = 'apim-${parNameSuffix}-hub-subnet'
param parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'
param parFoundryEndpoint = 'https://${parFoundryName}.services.ai.azure.com'
param parHubAppInsightsName = 'apins-${parNameSuffix}-hub'
param parHubLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-hub'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parLocation = config.location
param parMonitoringMetricsRole = config.roleDefinitions.monitoringMetricsPublisher
param parPublisherEmail = config.publisherEmail
param parPublisherName = config.publisherName
var parFoundryName = 'foundry-${parNameSuffix}'
var parNameSuffix string = config.nameSuffix

