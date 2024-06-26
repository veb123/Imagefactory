packer {
  required_version = ">=1.7.7"
  required_plugins {
    azure = {
      version = ">= 1.4.2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

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

locals {
  timestamp = timestamp()
}

source "azure-arm" "ubuntu22" {
  os_type                   = "Linux"
  build_resource_group_name = var.resource_group_name
  vm_size                   = var.vm_size

  client_id       = "6e48d520-1caf-44aa-90cc-4d6490cc95b3"
  client_secret   = "HfB8Q~nlJwALsqMnnrWbC~Kg41i1DdDo6sTkjcAX"
  subscription_id = "8d7d09a4-964e-4399-8282-3451df8712cb"
  tenant_id       = "d9890fe8-1294-4850-8f9f-5d5b972d4346"

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "${var.image_name}-${local.timestamp}"

  azure_tags = {
    project    = "ImageFactory-Corteva"
    build-time = local.timestamp
  }

  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"
}


locals {
  execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  timestamp       = regex_replace(timestamp(), "[- TZ:]", "")
}

build {

  name = "Packer-Azurelinux-build"
  sources = [
    "source.azure-arm.ubuntu22"
  ]

  provisioner "ansible" {
    playbook_file = "Ansible/Linux-playbook.yml"
  }

  provisioner "shell" {
    execute_command = local.execute_command
    inline = [
      "echo Installing nginx",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo 'Adding firewall rule...'",
      "sudo ufw allow proto tcp from any to any port 22,80,443",
      "echo 'y' | sudo ufw enable",
      "echo \"Variable value is $TEMP\" > demo.txt"
    ]
  }
}
