using 'apim.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
param parApimName = 'apim-${parAppName}-hub'
param parApimPublicIpName = 'pip-apim-${parAppName}-hub'
param parApimSku = config.apimSku
param parApimSubnetName = 'apim-${parAppName}-hub-subnet'
param parAppRegistrationName = 'app-reg-${config.nameSuffix}-entra'
param parFoundryEndpoint = 'https://${parFoundryName}.services.ai.azure.com'
param parHubAppInsightsName = 'apins-${parAppName}-hub'
param parHubLogAnalyticsWorkspaceName = 'law-${parAppName}-hub'
param parHubResourceGroupName = 'rg-${parAppName}-hub'
param parHubVirtualNetworkName = 'vnet-${parAppName}-hub'
param parLocation = config.location
param parMonitoringMetricsRole = config.roleDefinitions.monitoringMetricsPublisher
param parPublisherEmail = config.publisherEmail
param parPublisherName = config.publisherName
var parFoundryName = 'foundry-${parAppName}'
var parAppName string = config.nameSuffix

