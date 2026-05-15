using 'aca.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parLocation = config.location
param parSubscriptionId = config.subscriptionId
param parSpokeResourceGroupName  =  'rg-${parNameSuffix}-spoke'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'
param parContainerAppEnvName = replace('${parNameSuffix}-aca-env', '-', '')
param parShareName  = '${parNameSuffix}-share'
param parStorageAccountName = replace('${parNameSuffix}sa', '-', '')
param parVolumeMount = '${parShareName}-volume'
param parContainerName = '${parNameSuffix}-aca'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parSpokeEnvManagedId = 'umi-${parNameSuffix}-spoke'
param parContainerAppScaleSettings = {
  minReplicas: 1
  maxReplicas: 1
}
