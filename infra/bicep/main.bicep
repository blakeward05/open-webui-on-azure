targetScope = 'subscription'

// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

//ORDER OF DEPLOYMENT
// Core, Postgres, Container, Foundry, Network, Gateway, APIM

// ===========MARK: Variables for What to Deploy
param parStepsToDeploy object

// ========== MARK: Parameters ==========
param parAcaNsgName string
param parAcaSubnetAddressPrefix string
param parAcaSubnetName string
param parApimDnsName string
param parApimName string
param parApimNsgName string
param parApimPublicIpName string
param parApimRouteName string
param parApimSku string
param parApimSubnetAddressPrefix string
param parApimSubnetName string
param parAppGatewayDnsName string
param parAppGatewayName string
param parAppGatewayPublicIpName string
param parAppGatewaySku string
param parAppGatewaySubnetAddressPrefix string
param parAppGwPublicIpName string
param parAppGwSubnetName string
param parAppRegistrationName string
param parContainerAppEnvName string
param parContainerAppScaleSettings object
param parContainerName string
param parFoundryEndpoint string
param parFoundryName string
param parFoundrySku string
param parHubAppInsightsName string
param parHubEnvManagedId string
param parHubKeyVaultName string
param parHubLogAnalyticsWorkspaceName string
param parHubResourceGroupName string
param parHubVirtualNetworkAddressPrefix string
param parHubVirtualNetworkName string
param parKeyVaultUserIdRole string
param parKeyVaultAdminIdRole string
param parLocation string
param parMonitoringMetricsRole string
param parPeSubnetAddressPrefix string
param parPeSubnetName string
@secure()
@description('PostgreSQL administrator password. Pass inline via CLI: --parameters parPostgresAdminPassword=\'YourSecurePassword\'')
param parPostgresAdminPassword string
param parPostgresServerName string
param parPublisherEmail string
param parPublisherName string
param parShareName string
param parSpokeAppInsightsName string
param parSpokeEnvManagedId string
param parSpokeKeyVaultName string
param parSpokeLogAnalyticsWorkspaceName string
param parSpokeResourceGroupName string
param parSpokeVirtualNetworkAddressPrefix string
param parSpokeVirtualNetworkName string
param parSslCertificateName string
param parStorageAccountName string
param parSubscriptionId string
param parVolumeMount string



// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modCoreBuild './deployments/core/core.bicep' = if (parStepsToDeploy.core == 1) {
  params: {
  parHubAppInsightsName:parHubAppInsightsName
  parHubEnvManagedId:parHubEnvManagedId
  parHubKeyVaultName:parHubKeyVaultName
  parHubLogAnalyticsWorkspaceName:parHubLogAnalyticsWorkspaceName
  parHubResourceGroupName:parHubResourceGroupName
  parKeyVaultAdminIdRole:parKeyVaultAdminIdRole
  parKeyVaultUserIdRole:parKeyVaultUserIdRole
  parLocation:parLocation
  parShareName:parShareName
  parSpokeAppInsightsName:parSpokeAppInsightsName
  parSpokeEnvManagedId:parSpokeEnvManagedId
  parSpokeKeyVaultName:parSpokeKeyVaultName
  parSpokeLogAnalyticsWorkspaceName:parSpokeLogAnalyticsWorkspaceName
  parSpokeResourceGroupName:parSpokeResourceGroupName
  parStorageAccountName:parStorageAccountName
}
}


// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modPostGresBuild './deployments/postgres/pgsql.bicep' = if (parStepsToDeploy.postgres == 1) {
  params: {
  parLocation:parLocation
  parPostgresAdminPassword:parPostgresAdminPassword
  parPostgresServerName:parPostgresServerName
  parSpokeKeyVaultName:parSpokeKeyVaultName
  parSpokeResourceGroupName:parSpokeResourceGroupName

}
  dependsOn: [
    modCoreBuild
  ]
}

// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modNetworkBuild './deployments/network/network.bicep' = if (parStepsToDeploy.network == 1) {
  params: {
    parAcaNsgName:parAcaNsgName
    parAcaSubnetAddressPrefix:parAcaSubnetAddressPrefix
    parAcaSubnetName:parAcaSubnetName
    parApimDnsName:parApimDnsName
    parApimNsgName:parApimNsgName
    parApimPublicIpName:parApimPublicIpName
    parApimRouteName:parApimRouteName
    parApimSubnetAddressPrefix:parApimSubnetAddressPrefix
    parApimSubnetName:parApimSubnetName
    parAppGatewayDnsName:parAppGatewayDnsName
    parAppGatewaySubnetAddressPrefix:parAppGatewaySubnetAddressPrefix
    parAppGwPublicIpName:parAppGwPublicIpName
    parAppGwSubnetName:parAppGwSubnetName
    parContainerAppEnvName:parContainerAppEnvName
    parContainerName:parContainerName
    parHubResourceGroupName:parHubResourceGroupName
    parHubVirtualNetworkAddressPrefix:parHubVirtualNetworkAddressPrefix
    parHubVirtualNetworkName:parHubVirtualNetworkName
    parLocation:parLocation
    parPeSubnetAddressPrefix:parPeSubnetAddressPrefix
    parPeSubnetName:parPeSubnetName
    parSpokeResourceGroupName:parSpokeResourceGroupName
    parSpokeVirtualNetworkAddressPrefix:parSpokeVirtualNetworkAddressPrefix
    parSpokeVirtualNetworkName:parSpokeVirtualNetworkName
}
  dependsOn: [
    modCoreBuild
    modPostGresBuild
    modContainerBuild
    modFoundryBuild
  ]
}


// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modContainerBuild './deployments/container/aca.bicep' = if (parStepsToDeploy.container == 1) {
  params: {
    parAppGatewaySubnetAddressPrefix:parAppGatewaySubnetAddressPrefix
    parContainerAppEnvName:parContainerAppEnvName
    parContainerAppScaleSettings:parContainerAppScaleSettings
    parContainerName:parContainerName
    parKeyVaultUserIdRole:parKeyVaultUserIdRole
    parLocation:parLocation
    parShareName:parShareName
    parSpokeEnvManagedId:parSpokeEnvManagedId
    parSpokeKeyVaultName:parSpokeKeyVaultName
    parSpokeResourceGroupName:parSpokeResourceGroupName
    parAcaSubnetName:parAcaSubnetName
    parSpokeVirtualNetworkName: parSpokeVirtualNetworkName
    parStorageAccountName:parStorageAccountName
    parSubscriptionId:parSubscriptionId
    parVolumeMount:parVolumeMount
}
  dependsOn: [
    modCoreBuild
    modPostGresBuild
  ]
}

// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modFoundryBuild './deployments/foundry/foundry.bicep' = if (parStepsToDeploy.foundry == 1) {
  params: {
    parLocation:parLocation
    parSpokeResourceGroupName:parSpokeResourceGroupName
    parFoundryName:parFoundryName
    parFoundrySku:parFoundrySku

}
  dependsOn: [
    modCoreBuild
    modPostGresBuild
    modContainerBuild
  ]
}


// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modEntraRegBuild './deployments/entra/entra.bicep' = if (parStepsToDeploy.entra == 1) {
  params: {
    parAppGwPublicIpName:parAppGwPublicIpName
    parHubResourceGroupName:parHubResourceGroupName 
    parAppRegistrationName: parAppRegistrationName

}
  dependsOn: [
    modCoreBuild
    modPostGresBuild
    modContainerBuild
    modFoundryBuild
    modNetworkBuild
  ]
}


// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modApimBuild './deployments/apim/apim.bicep' = if (parStepsToDeploy.apim == 1) {
  params: {
    parApimName:parApimName
    parApimPublicIpName:parApimPublicIpName
    parApimSku:parApimSku
    parApimSubnetName:parApimSubnetName
    parAppRegistrationName:parAppRegistrationName
    parFoundryEndpoint:parFoundryEndpoint
    parHubAppInsightsName:parHubAppInsightsName
    parHubLogAnalyticsWorkspaceName:parHubLogAnalyticsWorkspaceName
    parHubResourceGroupName:parHubResourceGroupName
    parHubVirtualNetworkName:parHubVirtualNetworkName
    parLocation:parLocation
    parMonitoringMetricsRole:parMonitoringMetricsRole
    parPublisherEmail:parPublisherEmail
    parPublisherName:parPublisherName
  }
  dependsOn: [
    modCoreBuild
    modPostGresBuild
    modContainerBuild
    modFoundryBuild
    modNetworkBuild
    modEntraRegBuild
  ]
}


// MARK: - CORE First Step  Create Resource Groups, Identities etc
module modGatewayBuild './deployments/gateway/gateway.bicep' = if (parStepsToDeploy.gateway == 1) {
  params: {
    parAppGatewayName:parAppGatewayName
    parAppGatewayPublicIpName:parAppGatewayPublicIpName
    parAppGatewaySku:parAppGatewaySku
    parAppGwSubnetName:parAppGwSubnetName
    parContainerName:parContainerName
    parHubEnvManagedId:parHubEnvManagedId
    parHubKeyVaultName:parHubKeyVaultName
    parHubResourceGroupName:parHubResourceGroupName
    parHubVirtualNetworkName:parHubVirtualNetworkName
    parLocation:parLocation
    parSpokeResourceGroupName:parSpokeResourceGroupName
    parSslCertificateName:parSslCertificateName

    //BELOW NEEDED FOR CERTIFICATE ON OUTSIDE DOMAIN
    //parSpokeKeyVaultName:parSpokeKeyVaultName
    //parCustomDomain:parCustomDomain
    //parHubKeyVaultUri:parHubKeyVaultUri
    //parTrustedRootCertificateSecretName:parTrustedRootCertificateSecretName
  }
  dependsOn: [
    modCoreBuild
    modPostGresBuild
    modContainerBuild
    modFoundryBuild
    modNetworkBuild
    modEntraRegBuild
    modApimBuild
  ]
}
