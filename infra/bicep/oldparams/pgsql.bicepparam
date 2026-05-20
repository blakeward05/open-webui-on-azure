using 'pgsql.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
var parAppName string = config.nameSuffix

param parLocation = config.location
param parPostgresServerName = 'pgsql-${parAppName}'
param parSpokeKeyVaultName = 'kv-${parAppName}-spoke'
param parSpokeResourceGroupName = 'rg-${parAppName}-spoke'


