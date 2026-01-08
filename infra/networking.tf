### NETWORK
data "google_compute_network" "default" { # Would use custom VPC (created elsewhere) or shared VPC for ML applications
  name = "default"
}

### SUBNET
resource "google_compute_subnetwork" "subnet-1" {
  name                     = "${var.environment_map[local.env]}-${var.subnet-name}"
  ip_cidr_range            = var.subnet-cidr
  network                  = data.google_compute_network.default.self_link
  region                   = var.region
  private_ip_google_access = var.private_google_access

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

#tfsec:ignore:google-compute-no-public-ingress - Demo environment requires public access for testing
resource "google_compute_firewall" "default" {
  name    = "${var.environment_map[local.env]}-firewall"
  network = data.google_compute_network.default.self_link

  #tfsec:ignore:google-compute-no-public-ingress - ICMP required for network diagnostics
  allow {
    protocol = "icmp"
  }

  #tfsec:ignore:google-compute-no-public-ingress - TCP ports required for application access
  allow {
    protocol = "tcp"
    ports    = var.firewall-ports
  }

  source_tags = var.compute-source-tags
}