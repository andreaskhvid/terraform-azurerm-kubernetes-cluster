## define required providers here
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.19"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.27"
    }
  }
}
