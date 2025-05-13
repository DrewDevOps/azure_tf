terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "${var.env}-network-rg"
  vnet_name           = "${var.env}-vnet"

  subnet_map = {
    for name in var.subnet_names :
    name => cidrsubnet(var.vnet_address_space[0], 8, index(var.subnet_names, name))
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = local.resource_group_name
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = local.subnet_map

  name                 = "${var.env}-${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# NSGs per subnet
resource "azurerm_network_security_group" "nsg" {
  for_each = local.subnet_map

  name                = "${var.env}-${each.key}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSGs to Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = local.subnet_map

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
