
##### VM Part  ####################################

# Create public IPs
#resource "azurerm_public_ip" "myterraformpublicip" {
#  name                = "myPublicIP"
#  location            = "azurerm_resource_group.anf.location"
#  resource_group_name = azurerm_resource_group.anf.name
#  allocation_method   = "Dynamic"

#  tags = {
#    environment = "Terraform Demo"
#  }
#}





# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.anf.location
  resource_group_name = azurerm_resource_group.anf.name


  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = "Terraform Demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "anf" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.anf.name
  }

  byte_length = 8
}





# Create virtual machine
resource "azurerm_linux_virtual_machine" "anf" {
  name                  = "netappvm"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.anf.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_D4s_v3"
  


  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "netappvm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = "P@$$w0rd1234!"



}

##### VM Part  ####################################


resource "azurerm_network_interface" "win_nic" {
  name                = "win-nic"
  location            = azurerm_resource_group.anf.location
  resource_group_name = azurerm_resource_group.anf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "anfwinvm"
  resource_group_name = azurerm_resource_group.anf.name
  location            = azurerm_resource_group.anf.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.win_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
