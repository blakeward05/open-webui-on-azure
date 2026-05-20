targetScope = 'resourceGroup'

// ========== MARK: Parameters ==========
param parHubVnetId string
param parSpokeVirtualNetworkName string


// MARK: - Virtual Network Spoke to Hub Peering
resource spokeVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: parSpokeVirtualNetworkName
  resource hubPeering 'virtualNetworkPeerings@2024-01-01' = {
    name: 'spoke-to-hub-peering'
    properties: {
      remoteVirtualNetwork: {
        id: parHubVnetId
      }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
    }
  }
}
