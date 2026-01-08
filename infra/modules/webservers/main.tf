# ### PROVIDER -> Accounted for in infra/main.tf (i.e., the root module), as is custom
# provider "google" {
#   project = var.project_id
#   region  = var.region
#   zone    = var.zone
# }

### LOCAL VALUES
locals {
  prefix = var.prefix != "" ? "${var.prefix}-" : ""
}

### COMPUTE INSTANCES
#tfsec:ignore:google-compute-vm-disk-encryption-customer-key - Using Google-managed encryption is acceptable for demo environment
resource "google_compute_instance" "web-instances" {
  #checkov:skip=CKV_GCP_38:Using Google-managed encryption is acceptable for demo environment
  for_each     = var.server_settings
  project      = var.project_id
  name         = "${local.prefix}${lower(each.key)}"
  machine_type = each.value.machine_type
  labels       = each.value.labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_interface.network
    subnetwork = var.network_interface.subnetwork
  }

  metadata = {
    block-project-ssh-keys = "true"
  }

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}