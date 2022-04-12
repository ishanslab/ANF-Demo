# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {

  subscription_id = var.subid
  client_id       = var.clientid
  client_secret   = var.clientsecret
  tenant_id       = var.tenantid

  features {}
}



# ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_volume 

resource "azurerm_resource_group" "anf" {
  name     = "anf-resources"
  location = "east us"
}




##### NFS part ####################################


resource "azurerm_netapp_account" "anf" {
  name                = "anf-netappaccount"
  location            = azurerm_resource_group.anf.location
  resource_group_name = azurerm_resource_group.anf.name

  # Uncomment the below lines if you want to use AD connection
  #active_directory {
  #  username            = "aduser"
  #  password            = "aduserpwd"
  #  smb_server_name     = "SMBSERVER"
  #  dns_servers         = ["1.2.3.4"]
  #  domain              = "domain.com"
  #  organizational_unit = "OU=FirstLevel"
  #}
}

resource "azurerm_netapp_pool" "anf" {
  name                = "anf-netapppool"
  location            = azurerm_resource_group.anf.location
  resource_group_name = azurerm_resource_group.anf.name
  account_name        = azurerm_netapp_account.anf.name
  service_level       = "Ultra"
  size_in_tb          = 4
  #qos_type            = "Manual"
  }



# test block, for SMB Share   ########################### 

#resource "azurerm_netapp_volume" "anf" {
#  lifecycle {
#    prevent_destroy = false
#  }

#name                       = "anf-netappvolume"
#location                   = azurerm_resource_group.anf.location
#resource_group_name        = azurerm_resource_group.anf.name
#account_name               = azurerm_netapp_account.anf.name
#pool_name                  = azurerm_netapp_pool.anf.name
#volume_path                = "my-unique-file-path1"
#service_level              = "Ultra"
#subnet_id                  = azurerm_subnet.anf.id
#protocols                  = ["CIFS"]
#security_style             = "Ntfs"
#storage_quota_in_gb        = 1024
#snapshot_directory_visible = false

#export_policy_rule {
#  rule_index      = 1
#  allowed_clients = ["10.0.0.0/16"]
#  unix_read_only      = false
#  unix_read_write     = true
#  root_access_enabled = true
#  protocols_enabled   = ["NFSv4.1"]
#}

#}

# test block, for SMB Share ends  ###########################


resource "azurerm_netapp_volume" "example2" {
  lifecycle {
    prevent_destroy = false
  }

  name                       = "example2-netappvolume"
  location                   = azurerm_resource_group.anf.location
  resource_group_name        = azurerm_resource_group.anf.name
  account_name               = azurerm_netapp_account.anf.name
  pool_name                  = azurerm_netapp_pool.anf.name
  volume_path                = "my-unique-file-path2"
  service_level              = "Ultra"
  subnet_id                  = azurerm_subnet.anf.id
  protocols                  = ["NFSv4.1"]
  security_style             = "Unix"
  storage_quota_in_gb        = 1024
  snapshot_directory_visible = false

  export_policy_rule {
    rule_index          = 1
    allowed_clients     = ["10.0.0.0/16"]
    unix_read_only      = false
    unix_read_write     = true
    root_access_enabled = true
    protocols_enabled   = ["NFSv4.1"]
  }

}

##### NFS part ####################################


