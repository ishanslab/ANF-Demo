resource "azurerm_virtual_network" "anf" {
  name                = "anf-virtualnetwork"
  location            = azurerm_resource_group.anf.location
  resource_group_name = azurerm_resource_group.anf.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "anf" {
  name                 = "anf-subnet"
  resource_group_name  = azurerm_resource_group.anf.name
  virtual_network_name = azurerm_virtual_network.anf.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "netapp"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "vm"
  resource_group_name  = azurerm_resource_group.anf.name
  virtual_network_name = azurerm_virtual_network.anf.name
  address_prefixes     = ["10.0.3.0/24"]

}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.anf.name

  security_rule {
    name                       = "myaccess"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["22","3389"]
    source_address_prefix      = "10.10.10.10"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

