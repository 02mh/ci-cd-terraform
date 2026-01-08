variable "project_id" {
  type        = string
  description = "GCP Project ID used for provisioning resources."
}

variable "server_settings" {
  type        = map(object({ machine_type = string, labels = map(string) }))
  description = "Per-server configuration settings, including machine type and resource labels."
}

variable "prefix" {
  type        = string
  default     = "web"
  description = "Prefix applied to resource names for consistent naming across the environment."
}

variable "network_interface" {
  type        = object({ network = string, subnetwork = string })
  description = "Network interface configuration specifying the VPC network and subnetwork."
}

variable "region" {
  type        = string
  description = "Default Google Cloud Region where resources will be deployed."
}

variable "zone" {
  type        = string
  description = "Default Google Cloud Zone used for zonal resources."
}