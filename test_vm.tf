terraform {
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = "3.45.0"
}
}
}
provider "azurerm" {
#
features {}

}
resource "azurerm_resource_group" "example" {
  name     = "TF-DEMOVM"
  location = "central India"
}

resource "azurerm_virtual_network" "example" {
  name                = "TFDEMO-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "TFDEMO-SUBNET"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "TFDEMO-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "TFDEMO-IPs"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "TFDEMO-VM"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "dpsadmin"
  admin_password = "Password@123"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  #admin_ssh_key {
    #username   = "adminuser"
    #public_key = file("~/.ssh/id_rsa.pub")
  #}
  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}