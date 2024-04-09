variable "resource_group_name" {
  description = "The name of the resource group to create the image in."
  default     = "packerresoucegrp"
}

variable "vm_size" {
  description = "The size of the virtual machine."
  default     = "Standard_DS2_v2"
}

variable "image_name" {
  description = "The name of the custom managed image."
  default     = "my_custom_image"
}

variable "az_image_gallery" {
  description = "The name of the Azure Shared Image Gallery."
  default     = "my_image_gallery"
}

variable "az_gallery_img_def_name" {
  description = "The name of the image definition in the Azure Shared Image Gallery."
  default     = "Azure-linux-Image"
}

variable "az_regions" {
  description = "The list of regions to replicate the image in."
  type        = list(string)
  default     = ["centralindia"]
}

data "hcp-packer-image" "ubuntu22-nginx" {
  labels = {
    os_type = "Linux"
    name    = "ubuntu22"
    type    = "nginx"
  }
}

locals {
  timestamp = timestamp()
}

source "azure-arm" "ubuntu22" {
  os_type                   = "Linux"
  build_resource_group_name = var.resource_group_name
  vm_size                   = var.vm_size

  client_id       = "7d744bdf-a99f-4a3b-8e58-297d045c8656"
  client_secret   = "4895999f-b4c0-4176-96b2-837ab5353feb"
  subscription_id = "8d7d09a4-964e-4399-8282-3451df8712cb"
  tenant_id       = "d9890fe8-1294-4850-8f9f-5d5b972d4346"

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "${var.image_name}-${local.timestamp}"

  azure_tags = {
    project    = "ImageFactory-Corteva"
    build-time = local.timestamp
  }
}
