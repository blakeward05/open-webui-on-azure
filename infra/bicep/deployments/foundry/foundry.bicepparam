using 'foundry.bicep'

var config = loadJsonContent('../../shared/env_vars.json')

// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix

param parFoundryName = 'foundry-${parNameSuffix}'
param parFoundrySku = 'S0'
param parLocation = config.location
param parSpokeResourceGroupName = 'rg-${parNameSuffix}-spoke'

