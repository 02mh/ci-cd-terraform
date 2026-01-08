# https://developer.hashicorp.com/terraform/language/providers/requirements
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.50.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.53.0, < 8.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "tfe" {
  # Configuration options
  token = var.tf_cloud_token
}

provider "google" {
  # Default provider for authentication
  # Individual resources specify their target project via the 'project' parameter
  # This ensures resources are created in the correct project for each environment
}