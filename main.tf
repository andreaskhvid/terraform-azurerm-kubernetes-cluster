#########################################################################
############################### Locals ##################################
#########################################################################
# locals to manipulate and generate strings
locals {
  workload_fullname = "${var.workload_environment}-${var.workload_name}-${random_string.workload-random-id.result}"
}

#########################################################################
######################### Random Workload ID ############################
#########################################################################
# generate random id to postfix workload resources
resource "random_string" "workload-random-id" {
  length  = 4
  lower   = false
  numeric = false
  special = false
}

#########################################################################
########################### Resource Group ##############################
#########################################################################
# create resource group for the cluster
resource "azurerm_resource_group" "resource-group" {
  name     = "rg-${local.workload_fullname}"
  location = var.location
  tags     = var.tags
}

#########################################################################
########################### Virtual Network #############################
#########################################################################
# create virtual network for the cluster
resource "azurerm_virtual_network" "virtual-network" {
  name                = "vnet-${local.workload_fullname}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  address_space       = var.address_space
}
# create default subnet
resource "azurerm_subnet" "subnet-default" {
  resource_group_name  = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  name                 = "snet-default"
  address_prefixes     = ["10.150.0.0/24"]
}
/*
# configure DNS servers on vnet
resource "azurerm_virtual_network_dns_servers" "virtual-network-dns-servers" {
  virtual_network_id = azurerm_virtual_network.virtual-network.id
  dns_servers        = ["10.0.0.1", "10.0.0.2"]
}

# create vnet peering from workload to nva
resource "azurerm_virtual_network_peering" "virtual-network-peering-workload" {
  name = "peer-${local.workload_fullname}-to-nva"
  resource_group_name = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  remote_virtual_network_id = data.azurerm_virtual_network.data-virtual-network-nva.id
}
# create vnet peering from nva to workload
resource "azurerm_virtual_network_peering" "virtual-network-peering-nva" {
  name = "peer-nva-to-${local.workload_fullname}"
  resource_group_name = data.azurerm_resource_group.data-resource-group-nva.name
  virtual_network_name = data.azurerm_virtual_network.data-virtual-network-nva.name
  remote_virtual_network_id = azurerm_virtual_network.virtual-network.id
}
*/
# create default route table
resource "azurerm_route_table" "route-table" {
  name                = "rt-${local.workload_fullname}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name

  #route {
  #  name                   = "default_route"
  #  address_prefix         = "0.0.0.0/0"
  #  next_hop_type          = "VirtualAppliance"
  #  next_hop_in_ip_address = "10.130.0.4"
  #}
}
# associate route table with vnet
resource "azurerm_subnet_route_table_association" "route-table-association" {
  subnet_id      = azurerm_subnet.subnet-default.id
  route_table_id = azurerm_route_table.route-table.id
}

#########################################################################
########################### Private DNS Zone ############################
#########################################################################
# create private dns zone
resource "azurerm_private_dns_zone" "private-dns-zone" {
  name                = "privatelink.${lower(replace("${var.location}", " ", ""))}.azmk8s.io"
  resource_group_name = azurerm_resource_group.resource-group.name
}

#########################################################################
########################### Managed Identity ############################
#########################################################################
# create user assigned identity
resource "azurerm_user_assigned_identity" "user-assigned-identity" {
  name                = "id-${local.workload_fullname}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
}
# assign identity permissins on resource group
resource "azurerm_role_assignment" "identity-assign-rg" {
  scope                = azurerm_resource_group.resource-group.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.user-assigned-identity.principal_id
}
# assign identity permissions on private dns zone
resource "azurerm_role_assignment" "identity-assign-pdnsz" {
  scope                = azurerm_private_dns_zone.private-dns-zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.user-assigned-identity.principal_id
}

#########################################################################
################################# AKS ###################################
#########################################################################
# create aks cluster
resource "azurerm_kubernetes_cluster" "kubernetes-cluster" {
  name                = "aks-${local.workload_fullname}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  node_resource_group = "${azurerm_resource_group.resource-group.name}-nodes"
  sku_tier            = "Paid"
  tags                = var.tags

  dns_prefix_private_cluster = local.workload_fullname
  private_dns_zone_id        = azurerm_private_dns_zone.private-dns-zone.id

  private_cluster_enabled             = true
  public_network_access_enabled       = false
  role_based_access_control_enabled   = true
  private_cluster_public_fqdn_enabled = false

  automatic_channel_upgrade = null
  azure_policy_enabled      = true

  default_node_pool {
    name                          = "default"
    node_count                    = var.node_count
    vm_size                       = var.default_node_pool_vm_size
    capacity_reservation_group_id = var.capacity_reservation_group_id
    vnet_subnet_id                = azurerm_subnet.subnet-default.id
    type                          = "VirtualMachineScaleSets"
    enable_auto_scaling           = false
    only_critical_addons_enabled  = true
    ultra_ssd_enabled             = false
    enable_node_public_ip         = false
  }

  identity {
    type         = "UserAssigned"
    identity_ids = ["${azurerm_user_assigned_identity.user-assigned-identity.id}"]
  }

  network_profile {
    network_plugin     = "kubenet"
    pod_cidr           = "10.247.0.0/16"
    service_cidr       = "10.248.0.0/16"
    dns_service_ip     = "10.248.0.10"
    docker_bridge_cidr = "10.249.0.0/16"
    ip_versions        = ["IPv4"]
    load_balancer_sku  = "standard"
    outbound_type      = "userDefinedRouting"
  }
  depends_on = [
    azurerm_role_assignment.identity-assign-pdnsz,
    azurerm_subnet.subnet-default
  ]
}
