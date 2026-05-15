using 'core.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
param parHubAppInsightsName = 'apins-${parNameSuffix}-hub'
param parHubEnvManagedId = 'umi-${parNameSuffix}-hub'
param parHubKeyVaultName = 'kv-${parNameSuffix}-hub'
param parHubLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-hub'
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parLocation = config.location
param parShareName = '${parNameSuffix}-share'
param parSpokeAppInsightsName = 'apins-${parNameSuffix}-spoke'
param parSpokeEnvManagedId = 'umi-${parNameSuffix}-spoke'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'
param parSpokeLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-spoke'
param parSpokeResourceGroupName = 'rg-${parNameSuffix}-spoke'
param parStorageAccountName = replace('${parNameSuffix}sa', '-', '')
var parNameSuffix string = config.nameSuffix

