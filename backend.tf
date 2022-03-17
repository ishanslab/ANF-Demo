# Remote 
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "leafvillage" # Your Org name

    workspaces {
      name = "ANF-Demo" # Workspace name

    }
  }
}
  