variable "tf_cloud_token" {
  type        = string
  sensitive   = true
  description = "API token used to authenticate with Terraform Cloud."
}

variable "tf_cloud_organization" {
  type        = string
  description = "Name of the Terraform Cloud Organization."
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "OAuth Token ID from Terraform Cloud VCS connection (found in TFC org settings > VCS Providers)."
}

variable "dev-project-id" {
  type        = string
  description = "GCP Project ID used for resources in the DEV environment."
}

variable "qa-project-id" {
  type        = string
  description = "GCP Project ID used for resources in the QA environment."
}

variable "stage-project-id" {
  type        = string
  description = "GCP Project ID used for resources in the STAGE environment."
}

variable "prod-project-id" {
  type        = string
  description = "GCP Project ID used for resources in the PROD environment."
}


variable "vcs-identifier" {
  type        = string
  description = "Identifier for the version control system (VCS) connection."
}

variable "enable-services" {
  type        = list(string)
  default     = ["iam.googleapis.com", "cloudresourcemanager.googleapis.com", "compute.googleapis.com", "redis.googleapis.com"]
  description = "List of Google Cloud services to enable for this project."
}

variable "dev-main-branch" {
  type = string
  #default = ""
  description = "Name of the main Git branch used for the DEV environment."
}

variable "qa-main-branch" {
  type = string
  #default = ""
  description = "Name of the main Git branch used for the QA environment."
}

variable "stage-main-branch" {
  type = string
  #default = ""
  description = "Name of the main Git branch used for the STAGE environment."
}

variable "prod-main-branch" {
  type = string
  #default = ""
  description = "Name of the main Git branch used for the PROD environment."
}