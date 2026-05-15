
targetScope = 'resourceGroup'

param parApimName string
param parHubAppInsightsName string

// Configure LLM logging for the openai API diagnostic
resource resOpenAIDiagnosticLLMLogging 'Microsoft.ApiManagement/service/apis/diagnostics@2024-06-01-preview' = {
  name: '${parApimName}/openai/applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    logClientIp: true
    httpCorrelationProtocol: 'W3C'
    verbosity: 'information'
    loggerId: resourceId('Microsoft.ApiManagement/service/loggers', parApimName, parHubAppInsightsName)
    metrics: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    largeLanguageModel: {
      logs: 'enabled'
      requests: {
        maxSizeInBytes: 1024
        messages: 'all'
      }
      responses: {
        maxSizeInBytes: 1024
        messages: 'all'
      }
    }
  }
}
