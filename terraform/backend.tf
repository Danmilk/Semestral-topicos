terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stfprojtfstate2024"
    container_name       = "tfstate"
    key                  = "finalproject.tfstate"
  }
}
