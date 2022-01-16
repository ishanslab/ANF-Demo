# Remote 
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "leafvillage"

    workspaces {
      name = "netapp-ms"

    }
  }
}
  