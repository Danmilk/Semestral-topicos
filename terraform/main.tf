terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

# ──────────────────────────────────────────────
# Resource Group
# ──────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = "finalproject"
    environment = "dev"
  }
}

# ──────────────────────────────────────────────
# Red Virtual
# ──────────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project     = "finalproject"
    environment = "dev"
  }
}

# Subnet delegada a ACI
resource "azurerm_subnet" "aci" {
  name                 = "subnet-aci"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "aci-delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# ──────────────────────────────────────────────
# Azure Container Registry
# ──────────────────────────────────────────────
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    project     = "finalproject"
    environment = "dev"
  }
}

# ──────────────────────────────────────────────
# Network Profile para ACI dentro de la VNet
# ──────────────────────────────────────────────
resource "azurerm_network_profile" "aci" {
  name                = "np-aci-finalproject"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  container_network_interface {
    name = "cni-aci"
    ip_configuration {
      name      = "ipconfig-aci"
      subnet_id = azurerm_subnet.aci.id
    }
  }
}

# ──────────────────────────────────────────────
# Azure Container Instance
# ──────────────────────────────────────────────
resource "azurerm_container_group" "main" {
  name                = var.aci_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  # Credenciales para que ACI pueda hacer pull desde ACR
  image_registry_credential {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password = azurerm_container_registry.main.admin_password
  }

  container {
    name   = "app"
    image  = "${azurerm_container_registry.main.login_server}/finalproject:${var.image_tag}"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      NODE_ENV = "production"
      PORT     = "3000"
    }
  }

  tags = {
    project     = "finalproject"
    environment = "dev"
  }
}
