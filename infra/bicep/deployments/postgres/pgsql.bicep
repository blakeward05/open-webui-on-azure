targetScope = 'subscription'
// ms graph extensibility
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

// ========== Parameters ==========
param parLocation string
@description('PostgreSQL Flexible Server configuration')

param parPostgresConfig PostgresConfigType = {
  skuName: 'Standard_B1ms'
  tier: 'Burstable'
  version: '16'
  storageSizeGB: 32
  databaseName: 'openwebui'
  adminUsername: 'pgadmin'
}
@secure()
@description('PostgreSQL administrator password. Pass inline via CLI: --parameters parPostgresAdminPassword=\'YourSecurePassword\'')
param parPostgresAdminPassword string = ''
param parPostgresServerName string
param parSpokeKeyVaultName string
param parSpokeResourceGroupName string


// ========== Type Imports ==========
import { PostgresConfigType} from '../../shared/types.bicep'


// MARK: - PostgreSQL Flexible Server
module modPostgresServer 'br/public:avm/res/db-for-postgre-sql/flexible-server:0.15.1' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  params: {
    name: parPostgresServerName
    location: parLocation
    skuName: parPostgresConfig.skuName
    tier: parPostgresConfig.tier
    version: parPostgresConfig.version
    storageSizeGB: parPostgresConfig.storageSizeGB
    availabilityZone: -1
    administratorLogin: parPostgresConfig.adminUsername
    administratorLoginPassword: parPostgresAdminPassword
    // Enable password authentication for Open WebUI (required - Entra ID auth not supported)
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
    databases: [
      {
        name: parPostgresConfig.databaseName
        charset: 'UTF8'
        collation: 'en_US.utf8'
      }
    ]
    highAvailability: 'Disabled'
  }
}


// MARK: - Store PostgreSQL Connection String in Key Vault
module modPostgresConnectionStringSecret 'br/public:avm/res/key-vault/vault/secret:0.1.0' = {
  scope: resourceGroup(parSpokeResourceGroupName)
  name: 'postgres-connection-string-secret'
  params: {
    keyVaultName: parSpokeKeyVaultName
    name: 'postgres-connection-string'
    value: 'postgresql://${parPostgresConfig.adminUsername}:${parPostgresAdminPassword}@${modPostgresServer.outputs.?fqdn ?? ''}:5432/${parPostgresConfig.databaseName}?sslmode=require'
  }
}
