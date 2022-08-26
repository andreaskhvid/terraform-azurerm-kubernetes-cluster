## define locals, modules, resources etc. here
resource "azurerm_virtual_network" "virtual-network" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  address_space       = var.address_space
}

resource "azurerm_virtual_network_dns_servers" "virtual-network-dns-servers" {
  virtual_network_id = azurerm_virtual_network.virtual-network.id
  dns_servers        = var.dns_servers
}

resource "azurerm_subnet" "virtual-network-subnet" {
  for_each = var.subnets
  name = each.value["name"]
  resource_group_name = azurerm_virtual_network.virtual-network.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes = each.value["address_prefix"]
}