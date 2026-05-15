targetScope = 'resourceGroup'

// ========== MARK: Parameters ==========
param parHubVirtualNetworkName string
param parSpokeVnetId string

// MARK: - Virtual Network Hub to Spoke Peering
resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: parHubVirtualNetworkName
  resource spokePeering 'virtualNetworkPeerings@2024-01-01' = {
    name: 'hub-to-spoke-peering'
    properties: {
      remoteVirtualNetwork: {
        id: parSpokeVnetId
      }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
    }
  }
}

