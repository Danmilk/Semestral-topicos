variable "resource_group_name" {
  description = "Nombre del Resource Group en Azure"
  default     = "rg-finalproject-dev"
}

variable "location" {
  description = "Región de Azure"
  default     = "East US 2"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry (solo letras y números, único globalmente)"
  default     = "acrfinalproject"
}

variable "vnet_name" {
  description = "Nombre del Virtual Network"
  default     = "vnet-finalproject"
}

variable "aci_name" {
  description = "Nombre del Azure Container Instance"
  default     = "aci-finalproject"
}

variable "image_tag" {
  description = "Tag de la imagen Docker a desplegar"
  default     = "latest"
}
