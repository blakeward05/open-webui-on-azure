using 'aca.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

var parAppName string = config.nameSuffix


param parContainerAppEnvName = replace('${parAppName}-aca-env', '-', '')
param parContainerAppScaleSettings = {
  minReplicas: 1
  maxReplicas: 1
}
param parContainerName = '${parAppName}-aca'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parLocation = config.location
param parShareName = '${parAppName}-share'
param parSpokeEnvManagedId = 'umi-${parAppName}-spoke'
param parSpokeKeyVaultName = 'kv-${parAppName}-spoke'
param parSpokeResourceGroupName  =  'rg-${parAppName}-spoke'
param parStorageAccountName = replace('${parAppName}sa', '-', '')
param parSubscriptionId = config.subscriptionId
param parVolumeMount = '${parShareName}-volume'



