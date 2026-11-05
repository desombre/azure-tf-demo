locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      Owner       = var.owner
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source = "./modules/vnet"

  name                = var.vnet_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.address_space
  tags                = local.common_tags
}

locals {
  # Baseline is deliberately minimal: Private Link speaks HTTPS only, and its clients live
  # inside this VNet, so 443 from the VNet address space is the whole inbound surface.
  # Priorities 100-199 are reserved for these; var.pe_nsg_extra_rules start at 200.
  pe_nsg_base_rules = [
    {
      name                         = "Allow-PrivateLink-443-Inbound"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      source_address_prefix        = null
      source_address_prefixes      = var.address_space
      destination_port_range       = "443"
      destination_port_ranges      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    },
    {
      # Azure Load Balancer probes private endpoint NICs from the AzureLoadBalancer service
      # tag. Blocked probes mark the NIC down and the private endpoint stops resolving.
      name                         = "Allow-AzureLoadBalancer-Probe-Inbound"
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      source_address_prefix        = "AzureLoadBalancer"
      source_address_prefixes      = null
      destination_port_range       = "443"
      destination_port_ranges      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    },
  ]

  # Delegation is required for Azure CNI "managed subnet" clusters and reserves the subnet
  # for AKS alone, which matches the dedicated AKS Subnet in the target architecture.
  aks_delegations = var.aks_subnet_delegation_enabled ? [{
    name    = "AzureKubernetesServiceDelegation"
    service = "Microsoft.ContainerService/ManagedClusters"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    ]
  }] : []
}

module "aks_subnet" {
  source = "./modules/subnet"

  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = var.aks_subnet_address_prefixes
  delegations          = local.aks_delegations
}

module "private_endpoints_nsg" {
  source = "./modules/nsg"

  name                = var.private_endpoints_nsg_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  rules               = concat(local.pe_nsg_base_rules, var.pe_nsg_extra_rules)
  tags                = local.common_tags
}

module "private_endpoints_subnet" {
  source = "./modules/subnet"

  name                              = var.private_endpoints_subnet_name
  resource_group_name               = azurerm_resource_group.network.name
  virtual_network_name              = module.vnet.vnet_name
  address_prefixes                  = var.private_endpoints_subnet_address_prefixes
  private_endpoint_network_policies = var.private_endpoints_subnet_network_policies
  network_security_group_id         = module.private_endpoints_nsg.network_security_group_id
}
