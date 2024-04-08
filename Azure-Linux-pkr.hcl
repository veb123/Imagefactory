packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }
variable "client_id" {7d744bdf-a99f-4a3b-8e58-297d045c8656}
variable "client_secret" {4895999f-b4c0-4176-96b2-837ab5353feb}
variable "subscription_id" {8d7d09a4-964e-4399-8282-3451df8712cb}
variable "tenant_id" {d9890fe8-1294-4850-8f9f-5d5b972d4346}

variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "packer-rg"
}

variable "vm_size" {
  default = "Standard_DS2_v2"
}

variable "image_publisher" {
  default = "Canonical"
}

variable "image_offer" {
  default = "UbuntuServer"
}

variable "image_sku" {
  default = "18.04-LTS"
}

variable "ssh_username" {
  default = "packer"
}

variable "ssh_password" {
  default = "P@ssw0rd123!"
}

provider "azurerm" {
  version = "=2.41.0"
}

source "azure-arm" "ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  image_publisher = var.image_publisher
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  location        = var.location
  vm_size         = var.vm_size
}

build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "ansible" {
    playbook_file = "Ansible/playbooks/Linux-playbook.yml"
  }

  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password

  tags = {
    environment = "dev"
  }
}
