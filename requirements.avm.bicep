@description('Name for the environment')
param name string

@description('Azure region for the AVS Private Cloud')
param location string

@description('CIDR block for the virtual network')
param managementCidr string

@description('CIDR block for the GatewaySubnet')
param gatewaySubnetCidr string

@description('CIDR block for the AzureBastionSubnet')
param bastionSubnetCidr string

@description('CIDR block for the servers subnet')
param serversSubnetCidr string

var vnetName = '${name}-vnet'
var vnetResourceId = resourceId('Microsoft.Network/virtualNetworks',vnetName)
var bastionName = '${name}-bastion'
var bastionPublicIp = '${bastionName}-ip'
var expressRouteGatewayName = '${name}-express-route-gateway'

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'virtualNetworkDeployment'
  params: {
    // Required parameters
    addressPrefixes: [
      managementCidr
    ]
    name: vnetName
    // Non-required parameters
    location: location
    subnets: [
      {
        name: 'GatewaySubnet'
        addressPrefix: gatewaySubnetCidr
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: bastionSubnetCidr
      }
      {
        name: 'servers'
        addressPrefix: serversSubnetCidr
      }
    ]
  }
}

module bastion 'br/public:avm/res/network/bastion-host:0.6.1' = {
  name: 'bastionDeployment'
  params: {
    // Required parameters
    name: bastionName
    virtualNetworkResourceId: vnetResourceId
    // Non-required parameters
    location: location
    skuName: 'Basic'
    publicIPAddressObject: {
      name: bastionPublicIp
      location: location
      sku: {
        name: 'Standard'
      }
    }
  }
  dependsOn: [
    virtualNetwork
  ]
}

module expressRouteGateway 'br/public:avm/res/network/virtual-network-gateway:0.6.2' = {
  name: 'virtualNetworkGatewayDeployment'
  params: {
    // Required parameters
    clusterSettings: {
      clusterMode: 'activePassiveBgp'
    }
    gatewayType: 'ExpressRoute'
    name: expressRouteGatewayName
    virtualNetworkResourceId: vnetResourceId
    // Non-required parameters
    skuName: 'Standard'
    location: location
  }
}

@description('Admin password for the virtual machine')
@secure()
param adminPassword string

@description('Admin user name for virtual machine')
param adminUserName string

var vmssName = '${name}-vmss'
var serversSubnetResourceId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'servers')
var vmssNicName = '${name}-vmss-nic'

module vmss 'br/public:avm/res/compute/virtual-machine-scale-set:0.11.0' = {
  name: 'vmssDeployment'
  params: {
    adminUsername: adminUserName
    adminPassword: adminPassword
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: vmssName
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            properties: {
              subnet: {
                id: serversSubnetResourceId
              }
              primary: true
            }
          }
        ]
        nicSuffix: '-nic-01'
        name: vmssNicName
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      createOption: 'fromImage'
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    encryptionAtHost: false
    osType: 'Windows'
    skuCapacity: 3
    location: location
    skuName: 'Standard_B2ms'
  }
  dependsOn: [
    virtualNetwork
  ]
}

@description('SKU for the AVS Private Cloud (e.g., AV36, AV36P, AV52)')
param sku string

@description('Number of hosts')
param hostCount int

@description('CIDR block for the management network')
param avsManagementCidr string

var privateCloudName = '${name}-avs'

resource avs 'Microsoft.AVS/privateClouds@2023-09-01' = {
  name: privateCloudName
  location: location
  sku: {
    name: sku
  }
  properties: {
    identitySources: []
    internet: 'enabled'
    managementCluster: {
      clusterSize: hostCount
    }
    networkBlock: avsManagementCidr
  }
    dependsOn: [
    virtualNetwork
  ]
}

var avsAuthorizationName = '${name}-avs-auth'

resource avsAuthorization 'Microsoft.AVS/privateClouds/authorizations@2023-09-01' = {
  name: avsAuthorizationName
  parent: avs
  properties: {}
}
