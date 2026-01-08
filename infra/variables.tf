
variable "project-id" {
  type        = string
  default     = ""
  description = "GCP Project ID"
}

variable "gcp_credentials" {
  type        = string
  default     = null
  description = "Path to the GCP service account key file (optional). If not provided, Application Default Credentials will be used."
}

variable "org_id" {
  type        = string
  default     = ""
  description = "Google Cloud Organization ID used for resource and policy management."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default Google Cloud Region where resources will be deployed."
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "Default Google Cloud Zone used for zonal resources."
}

variable "subnet-name" {
  type        = string
  default     = "subnet1"
  description = "Name of the subnet to create or use within the Virtual Private Cloud (VPC)."
}

variable "subnet-cidr" {
  type        = string
  default     = "10.127.0.0/20"
  description = "CIDR range for the subnet used by this environment."
}

variable "private_google_access" {
  type        = bool
  default     = true
  description = "Enables Private Google Access for resources without external IP addresses."
}

variable "firewall-ports" {
  type        = list(string)
  default     = ["80", "8080", "1000-2000", "22"]
  description = "List of ports or port ranges to allow through the firewall."
}

variable "compute-source-tags" {
  type        = list(string)
  default     = ["web"]
  description = "Network tags applied to compute instances for firewall rule targeting."
}

variable "project_id_map" {
  type        = map(string)
  description = "Mapping of environments to their respective Google Cloud Project IDs."
}

variable "target_environment" {
  type        = string
  default     = "DEV"
  description = "Selected environment used to determine configuration settings. Can be overridden locally via TF_VAR_target_environment or workspaces."
}

variable "environment_list" {
  type        = list(string)
  default     = ["DEV", "QA", "STAGE", "PROD"]
  description = "List of valid deployment environments."
}

variable "environment_map" {
  type = map(string)
  default = {
    "DEV"   = "dev",
    "QA"    = "qa",
    "STAGE" = "stage",
    "PROD"  = "prod"
  }
}

variable "environment_machine_type" {
  type = map(string)
  default = {
    "DEV"   = "f1-micro",
    "QA"    = "e2-micro",
    "STAGE" = "e2-micro",
    "PROD"  = "e2-micro" # e2-medium or much higher if not paying!
  }
  description = "Mapping of environments to their default compute machine types."
}

variable "environment_instance_settings" {
  type = map(object({ machine_type = string, labels = map(string) }))
  default = {
    "DEV" = {
      machine_type = "f1-micro"
      labels = {
        environment = "dev"
      }
    },
    "QA" = {
      machine_type = "e2-micro"
      labels = {
        environment = "qa"
      }
    },
    "STAGE" = {
      machine_type = "e2-micro"
      labels = {
        environment = "stage"
      }
    },
    "PROD" = {
      machine_type = "e2-micro"
      labels = {
        environment = "prod"
      }
    }
  }
  description = "Per-environment instance settings, including machine type and resource labels."
}