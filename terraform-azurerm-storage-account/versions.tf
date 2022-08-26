## define required provider versions here
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.19"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-3"
    }
  }
}
