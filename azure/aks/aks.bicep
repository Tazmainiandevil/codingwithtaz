@description('The environment prefix of the Managed Cluster resource e.g. dev, prod, etc.')
param prefix string
@description('The name of the Managed Cluster resource')
param clusterName string
@description('Resource location')
param location string = resourceGroup().location
@description('Kubernetes version to use')
param kubernetesVersion string = '1.20.7'
@description('The VM Size to use for each node')
param nodeVmSize string
@minValue(1)
@maxValue(50)
@description('The number of nodes for the cluster.')
param nodeCount int
@maxValue(100)
@description('Max number of nodes to scale up to')
param maxNodeCount int
@description('The node pool name')
param nodePoolName string = 'linux1'
@minValue(0)
@maxValue(1023)
@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize')
param osDiskSizeGB int
param nodeAdminUsername string
@description('Availability zones to use for the cluster nodes')
param availabilityZones array = [
  '1'
  '2'
  '3'
]
@description('Allow the cluster to auto scale to the max node count')
param enableAutoScaling bool = true
@description('SSH RSA public key for all the nodes')
@secure()
param sshPublicKey string
@description('Tags for the resources')
param tags object
@description('Log Analytics Workspace Tier')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
  'Premium'
])
param workspaceTier string
@allowed([
  'azure'  
])
@description('Network plugin used for building Kubernetes network')
param networkPlugin string = 'azure'
@description('Subnet id to use for the cluster')
param subnetId string
@description('Cluster services IP range')
param serviceCidr string = '10.0.0.0/16'
@description('DNS Service IP address')
param dnsServiceIP string = '10.0.0.10'
@description('Docker Bridge IP range')
param dockerBridgeCidr string = '172.17.0.1/16'
@description('An array of AAD group object ids for administration')
param adminGroupObjectIDs array = []

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${prefix}-oms-${clusterName}-${resourceGroup().location}'
  location: location
  properties: {
    sku: {
      name: workspaceTier
    }
  }
  tags: tags
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: '${prefix}-aks-${clusterName}-${location}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags  
  properties: {
    nodeResourceGroup: 'rg-${prefix}-aks-nodes-${clusterName}-${location}'
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true    
    agentPoolProfiles: [
      {        
        name: nodePoolName
        osDiskSizeGB: osDiskSizeGB
        osDiskType: 'Ephemeral'        
        count: nodeCount
        enableAutoScaling: enableAutoScaling
        minCount: nodeCount
        maxCount: maxNodeCount
        vmSize: nodeVmSize        
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        availabilityZones: availabilityZones
        enableEncryptionAtHost: true
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {      
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }
    aadProfile: !empty(adminGroupObjectIDs) ? {
      managed: true
      adminGroupObjectIDs: adminGroupObjectIDs
    } : null
    addonProfiles: {
      azurepolicy: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }   
    }
    linuxProfile: {      
      adminUsername: nodeAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
          }
        ]
      }      
    }
  }

  dependsOn: [
    logAnalyticsWorkspace    
  ]
}

output controlPlaneFQDN string = reference('${prefix}-aks-${clusterName}-${location}').fqdn
output clusterPrincipalID string = aksCluster.properties.identityProfile.kubeletidentity.objectId
