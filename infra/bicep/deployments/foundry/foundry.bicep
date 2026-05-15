targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== Parameters ==========
param parFoundryName string
param parFoundrySku string
param parLocation string
param parSpokeResourceGroupName string


// MARK: - Microsoft Foundry (AI Services)
module modFoundry 'br/public:avm/res/cognitive-services/account:0.14.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parFoundryName
    location: parLocation
    kind: 'AIServices'
    sku: parFoundrySku
    disableLocalAuth: true
    managedIdentities: {
      systemAssigned: true
    }
    allowProjectManagement: true
    publicNetworkAccess: 'Enabled'
    /*
    networkAcls: {
      defaultAction: 'Deny'
    }
    privateEndpoints: [
      {
        name: '${parNamePrefix}-foundry-pe'
        subnetResourceId: resHubPeSubnet.id
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: varFoundryPrivateDnsZoneConfigs
        }
      }
    ]
      */
    //customSubDomainName: replace('${parNamePrefix}-foundry', '-', '')
    //deployments: parFoundryDeployments
    // APIM RBAC is assigned in main.bicep after APIM is created
  }
}
