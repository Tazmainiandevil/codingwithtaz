@description('The virtual network name')
param vnetName string
@description('The name of the subnet')
param subnetName string
@description('The virtual network address prefixes')
param vnetAddressPrefixes array
@description('The subnet address prefix')
param subnetAddressPrefix string
@description('Tags for the resources')
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }      
    ]
  }
  tags: tags
}

output subnetId string = '${vnet.id}/subnets/${subnetName}'
