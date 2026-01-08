### LOCALS
locals {
  # Map workspace names to environment keys
  # This allows local 'terraform workspace select' to work
  workspace_to_env = {
    "app-dev"   = "DEV"
    "app-qa"    = "QA"
    "app-stage" = "STAGE"
    "app-prod"  = "PROD"
    "default"   = "DEV" # Fallback for local development
  }

  # Determine the effective environment:
  # 1. Use workspace if it matches our map
  # 2. Otherwise use the target_environment variable (which can be set via TF_VAR or TFC variable)
  env = lookup(local.workspace_to_env, terraform.workspace, var.target_environment)

  # Effective Project ID:
  # When running in TF Cloud, use the workspace-specific project-id variable
  # When running locally, fall back to project_id_map lookup
  project_id = var.project-id != "" ? var.project-id : var.project_id_map[local.env]
}

### PROVIDER
provider "google" {
  project     = local.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.gcp_credentials
}

### COMPUTE
## NGINX PROXY
#tfsec:ignore:google-compute-no-public-ip - Nginx proxy requires public IP for external access
#tfsec:ignore:google-compute-vm-disk-encryption-customer-key - Using Google-managed encryption is acceptable for demo environment
resource "google_compute_instance" "nginx_instance" {
  #checkov:skip=CKV_GCP_40:Nginx proxy requires public IP for external access
  #checkov:skip=CKV_GCP_38:Using Google-managed encryption is acceptable for demo environment
  name         = "${var.environment_map[local.env]}-nginx-proxy"
  machine_type = var.environment_machine_type[local.env]
  labels = {
    environment = var.environment_map[local.env]
  }
  tags = var.compute-source-tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
    access_config {

    }
  }

  metadata = {
    block-project-ssh-keys = "true"
  }

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

module "webservers" {
  source     = "./modules/webservers"
  project_id = local.project_id
  server_settings = {
    "${var.environment_map[local.env]}-web-server" = var.environment_instance_settings[local.env]
  }
  region = var.region
  zone   = var.zone
  network_interface = {
    network    = data.google_compute_network.default.self_link,
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }
}

### DB
#tfsec:ignore:google-compute-vm-disk-encryption-customer-key - Using Google-managed encryption is acceptable for demo environment
resource "google_compute_instance" "mysqldb" {
  #checkov:skip=CKV_GCP_38:Using Google-managed encryption is acceptable for demo environment
  name         = "${var.environment_map[local.env]}-mysqldb"
  machine_type = var.environment_machine_type[local.env]
  labels = {
    environment = var.environment_map[local.env]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }

  metadata = {
    block-project-ssh-keys = "true"
  }

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}