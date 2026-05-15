using 'pgsql.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parLocation = config.location
param parSpokeResourceGroupName  =  'rg-${parNameSuffix}-spoke'
param parPostgresServerName = 'pgsql-${parNameSuffix}'
param parSpokeKeyVaultName = 'kv-${parNameSuffix}-spoke'

