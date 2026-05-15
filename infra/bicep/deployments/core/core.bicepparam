using 'core.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parLocation = config.location
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parSpokeResourceGroupName  =  'rg-${parNameSuffix}-spoke'
param parHubKeyVaultName = 'kv-${parNameSuffix}-hub'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'
param parStorageAccountName = replace('${parNameSuffix}sa', '-', '')
param parShareName  = '${parNameSuffix}-share'
param parHubLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-hub'
param parHubAppInsightsName = 'apins-${parNameSuffix}-hub'
param parSpokeLogAnalyticsWorkspaceName = 'law-${parNameSuffix}-spoke'
param parSpokeAppInsightsName = 'apins-${parNameSuffix}-spoke'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parSpokeEnvManagedId = 'umi-${parNameSuffix}-spoke'
param parHubEnvManagedId = 'umi-${parNameSuffix}-hub'
