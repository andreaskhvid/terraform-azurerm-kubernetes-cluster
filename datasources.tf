data "azurerm_resource_group" "data-resource-group-nva" {
  name = "rg-dev-fw"
}

data "azurerm_virtual_network" "data-virtual-network-nva" {
  name = "vnet-afw-dev"
  resource_group_name = "rg-dev-fw"
}
