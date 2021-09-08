@description('Naming prefix for the resources e.g. dev, test, prod')
param prefix string
@description('The public SSH key')
@secure()
param publicsshKey string
@description('The name of the cluster')
param clusterName string
@description('The location of the resources')
param location string = resourceGroup().location
@description('The admin username for the nodes in the cluster')
param nodeAdminUsername string
@description('An array of AAD group object ids to give administrative access.')
param adminGroupObjectIDs array = []
@description('The VM size to use in the cluster')
param nodeVmSize string
@minValue(1)
@maxValue(50)
@description('The number of nodes for the cluster.')
param nodeCount int = 1
@maxValue(100)
@description('Max number of nodes to scale up to')
param maxNodeCount int = 3
@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize')
param osDiskSizeGB int
@description('Log Analytics Workspace Tier')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
  'Premium'
])
param workspaceTier string
@description('The virtual network address prefixes')
param vnetAddressPrefixes array
@description('The subnet address prefix')
param subnetAddressPrefix string
@description('Tags for the resources')
param tags object

module vnet 'vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    vnetName: '${prefix}-vnet-${clusterName}-${location}'
    subnetName: '${prefix}-snet-${clusterName}-${location}'
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetAddressPrefix: subnetAddressPrefix
    tags: tags
  }
}

module aks 'aks.bicep' = {
  name: 'aksDeploy'
  params: {
    prefix: prefix
    clusterName: clusterName    
    subnetId: vnet.outputs.subnetId
    nodeAdminUsername: nodeAdminUsername
    adminGroupObjectIDs: adminGroupObjectIDs
    nodeVmSize: nodeVmSize
    nodeCount: nodeCount
    maxNodeCount: maxNodeCount
    osDiskSizeGB: osDiskSizeGB
    sshPublicKey: publicsshKey
    workspaceTier: workspaceTier
    tags: tags
  }

  dependsOn: [
    vnet
  ]
}

module registry 'registry.bicep' = {
  name: 'registryDeploy'
  params: {
    registryName: 'acr${clusterName}'
    aksPrincipalId: aks.outputs.clusterPrincipalID
    tags: tags
  }

  dependsOn: [
    aks
  ]
}
