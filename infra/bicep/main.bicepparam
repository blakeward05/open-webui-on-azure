using 'main.bicep'

// Change values as required for your setup/demo/poc


//Steps to run

var varStepsToDeploy object = {
  core: 0
  postgres: 0
  container: 1
  foundry: 0
  network: 0
  entra: 0
  apim: 0
  gateway: 0
}

var config = {
  appName: 'full-openwebui'
  location: 'centralus'
  subscriptionId: '3fab28e9-d6dd-4468-8e3a-ecfa0cff0498'
  subscriptionName: 'open-sub-second'
  foundrySku: 'S0'
  apimSku: 'Developer'
  appGatewaySku: 'Standard_v2'
  publisherName: 'Blake Ward'
  publisherEmail: 'blakeward05@yahoo.com'
  foundryEndpointDomain: '.services.ai.azure.com'
  spokeNetwork: '10.0.4.0/22'
  hubNetwork: '10.0.0.0/24'
  apimSubnet: '10.0.0.0/28'
  peSubnet: '10.0.0.128/28'
  appgwSubnet: '10.0.0.64/26'
  acaSubnet: '10.0.4.0/23'
  codes: {
    apim: 'apim'
    appinsight: 'appins'
    appreg: 'appreg'
    container: 'aca'
    dns: 'dns'
    entra: 'entra'
    environment: 'env'
    foundry: 'foundry'
    gateway: 'apgw'
    hub: 'hub'
    identity: 'umi'
    keyvault: 'kv'
    loganalytics: 'law'
    netsec: 'nsg'
    postgres: 'pgsql'
    privateendpoint: 'pe'
    publicip: 'pip'
    resourcegroup: 'rg'
    route: 'rt'
    share: 'share'
    spoke: 'spoke'
    storage: 'sa'
    subnet: 'subnet'
    vnet: 'vnet'
    volume: 'vol'

  }
  roleDefinitions: {
    keyVaultSecretsUser: '4633458b-17de-408a-b874-0445c86b69e6'
    keyVaultAdministrator: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
    cognitiveServicesUser: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    azureAIUser: '53ca6127-db72-4b80-b1b0-d745d6d5456d'
    monitoringMetricsPublisher: '3913510d-42f4-4e42-8a64-420c390055eb'
  }
  sslCertificateSecretName: 'sll-full-openweb-cert'  //needs to be created in Hub Keyvault after core runs
}

param parStepsToDeploy = varStepsToDeploy

var parAppName string = config.appName


// ========== MARK: Parameters ==========
param parAcaNsgName = '${config.codes.netsec}-${parAppName}-${config.codes.container}'
param parAcaSubnetAddressPrefix = config.acaSubnet
param parAcaSubnetName = '${config.codes.container}-${parAppName}-${config.codes.spoke}-${config.codes.subnet}'
param parApimDnsName = '${config.codes.apim}-${config.codes.dns}-${parAppName}'
param parApimName = '${config.codes.apim}-${parAppName}-${config.codes.hub}'
param parApimNsgName = '${config.codes.netsec}-${parAppName}-${config.codes.apim}'
param parApimPublicIpName = '${config.codes.publicip}-${config.codes.apim}-${parAppName}-${config.codes.hub}'
param parApimRouteName = '${config.codes.route}-${parAppName}-${config.codes.apim}'
param parApimSku = config.apimSku
param parApimSubnetAddressPrefix = config.apimSubnet
param parApimSubnetName = '${config.codes.apim}-${parAppName}-${config.codes.hub}-${config.codes.subnet}'
param parAppGatewayDnsName = '${config.codes.gateway}-${config.codes.dns}-${parAppName}'
param parAppGatewayName = '${config.codes.gateway}-${parAppName}-${config.codes.hub}'
param parAppGatewayPublicIpName = '${config.codes.publicip}-${config.codes.gateway}-${parAppName}-${config.codes.hub}'
param parAppGatewaySku = config.appGatewaySku
param parAppGatewaySubnetAddressPrefix = config.appgwSubnet
param parAppGwPublicIpName = '${config.codes.publicip}-${config.codes.gateway}-${parAppName}-${config.codes.hub}'
param parAppGwSubnetName = '${config.codes.gateway}-${parAppName}-${config.codes.hub}-${config.codes.subnet}'
param parAppRegistrationName = '${config.codes.appreg}-${parAppName}-${config.codes.entra}'
param parContainerAppEnvName = replace('${parAppName}${config.codes.container}${config.codes.environment}', '-', '')
param parContainerAppScaleSettings = {
  minReplicas: 1
  maxReplicas: 1
}
 
param parContainerName = '${parAppName}-${config.codes.container}'
param parFoundryEndpoint = 'https://${parFoundryName}${config.foundryEndpointDomain}'
param parFoundryName = '${config.codes.foundry}-${parAppName}'
param parFoundrySku = config.foundrySku
param parHubAppInsightsName = '${config.codes.appinsight}-${parAppName}-${config.codes.hub}'
param parHubEnvManagedId = '${config.codes.identity}-${parAppName}-${config.codes.hub}'
param parHubKeyVaultName = '${config.codes.keyvault}-${parAppName}-${config.codes.hub}'
param parHubLogAnalyticsWorkspaceName = '${config.codes.loganalytics}-${parAppName}-${config.codes.hub}'
param parHubResourceGroupName = '${config.codes.resourcegroup}-${parAppName}-${config.codes.hub}'
param parHubVirtualNetworkAddressPrefix = config.hubNetwork
param parHubVirtualNetworkName = '${config.codes.vnet}-${parAppName}-${config.codes.hub}'
param parKeyVaultUserIdRole= config.roleDefinitions.keyVaultSecretsUser
param parKeyVaultAdminIdRole = config.roleDefinitions.keyVaultAdministrator
param parLocation = config.location
param parMonitoringMetricsRole = config.roleDefinitions.monitoringMetricsPublisher
param parPeSubnetAddressPrefix = config.peSubnet
param parPeSubnetName = '${config.codes.privateendpoint}-${parAppName}-${config.codes.hub}-${config.codes.subnet}'
param parPostgresAdminPassword = ''
param parPostgresServerName = '${config.codes.postgres}-${parAppName}'
param parPublisherEmail = config.publisherEmail
param parPublisherName = config.publisherName
param parShareName = '${parAppName}-${config.codes.share}'
param parSpokeAppInsightsName = '${config.codes.appinsight}-${parAppName}-${config.codes.spoke}'
param parSpokeEnvManagedId = '${config.codes.identity}-${parAppName}-${config.codes.spoke}'
param parSpokeKeyVaultName = '${config.codes.keyvault}-${parAppName}-${config.codes.spoke}'
param parSpokeLogAnalyticsWorkspaceName = '${config.codes.loganalytics}-${parAppName}-${config.codes.spoke}'
param parSpokeResourceGroupName = '${config.codes.resourcegroup}-${parAppName}-${config.codes.spoke}'
param parSpokeVirtualNetworkAddressPrefix = config.spokeNetwork
param parSpokeVirtualNetworkName = '${config.codes.vnet}-${parAppName}-${config.codes.spoke}'
param parSslCertificateName = config.sslCertificateSecretName
param parStorageAccountName = replace('${parAppName}${config.codes.storage}', '-', '')
param parSubscriptionId = config.subscriptionId
param parVolumeMount = '${parShareName}-${config.codes.volume}'


