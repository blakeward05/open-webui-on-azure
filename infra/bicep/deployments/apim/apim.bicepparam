using 'apim.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
var parFoundryName = 'foundry-${parNameSuffix}'
param parLocation = config.location
param parApimName = 'apim-${parNameSuffix}-hub'
param parApimSku = config.apimSku
param parApimPublicIpName = 'pip-apim-${parNameSuffix}-hub'
param parApimSubnetName = 'apim-${parNameSuffix}-hub-subnet'
param parPublisherEmail = config.publisherEmail
param parPublisherName = config.publisherName
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parHubVirtualNetworkName = 'vnet-${parNameSuffix}-hub'
param parHubLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-hub'
param parHubAppInsightsName = 'apins-${parNameSuffix}-hub'
param parMonitoringMetricsRole = config.roleDefinitions.monitoringMetricsPublisher
param parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'
param parFoundryEndpoint = 'https://${parFoundryName}.services.ai.azure.com'
