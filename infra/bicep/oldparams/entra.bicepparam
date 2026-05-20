using 'entra.bicep'

var config = loadJsonContent('../../shared/env_vars.json')


// Change values as required for your setup/demo/poc
var parAppName string = config.nameSuffix
param parHubResourceGroupName = 'rg-${parAppName}-hub'
param parAppGwPublicIpName = 'pip-appgw-${parAppName}-hub'
