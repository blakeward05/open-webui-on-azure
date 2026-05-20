#deploys 

NOTES
1. Main runs all the sub scripts which are in the deployment folder
2. You can run them all at once, or piece by piece by changing the stepsToDeploy parameters in the main.bicepparam file
3. If you are full redeploying with with the same naming conventions, you need to hard delete the foundry instance and the key vaults as those names have to be unique

var varStepsToDeploy object = {
  core: 0
  postgres: 1
  container: 1
  foundry: 1
  network: 1
  entra: 1
  gateway: 1
  apim: 1

}

Order
1.Core, Postgres, Container

az deployment sub create --location centralus --template-file infra/bicep/main.bicep --parameters infra/bicep/main.bicepparam parPostgresAdminPassword=8u5!n355!n7311!93n


var varStepsToDeploy object = {
  core: 1
  postgres: 1
  container: 1
  foundry: 0
  network: 0
  entra: 0
  apim: 0
  gateway: 0
}

Create certificate in the hub keyvault for ssl and save the name in the config in the main.biccepparam file - this can't be done programatically as of now and is needed for the gateway setup

Check container to make sure secret for database-url is mapped to spoke key vault secret and is in the environment.  Also add access key to the container environment volume

2. One by One

Change the 0 to 1 as you deploy

az deployment sub create --location centralus --template-file infra/bicep/main.bicep --parameters infra/bicep/main.bicepparam parPostgresAdminPassword=8u5!n355!n7311!93n

