using 'aca.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

var parNameSuffix string = config.nameSuffix


param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parContainerAppScaleSettings = {
  minReplicas: 1
  maxReplicas: 1
}
param parContainerName = '${parNameSuffix}-aca'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parLocation = config.location
param parShareName = '${parNameSuffix}-share'
param parSpokeEnvManagedId = 'umi-${parNameSuffix}-spoke'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'
param parSpokeResourceGroupName  =  'rg-${parNameSuffix}-spoke'
param parStorageAccountName = replace('${parNameSuffix}sa', '-', '')
param parSubscriptionId = config.subscriptionId
param parVolumeMount = '${parShareName}-volume'



