using 'entra.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parNameSuffix string = config.nameSuffix
param parHubResourceGroupName = 'rg-${parNameSuffix}-hub'
param parAppGwPublicIpName = 'pip-appgw-${parNameSuffix}-hub'
