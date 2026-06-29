terraform {
  backend "azurerm" {
    resource_group_name  = "rg-finalproject-dev"
    storage_account_name = "stfinalprojecttf"
    container_name       = "tfstate"
    key                  = "finalproject.tfstate"
  }
}
