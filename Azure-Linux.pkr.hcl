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

variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}

variable "location" {
  default = "Southeast Asia"
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
  default = "root"
}

variable "ssh_password" {
  default = ""
}

provider "azurerm" {
  version = "2.41.0"
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