# Local backend for CICD module bootstrap
# This module is run locally first to set up Terraform Cloud workspaces
# After workspaces are created, the main infra uses Terraform Cloud backend
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
