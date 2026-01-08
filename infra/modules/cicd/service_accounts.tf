module "service_account_dev" {
  #checkov:skip=CKV_TF_1:Using Terraform Registry with semantic versioning is acceptable for this module
  source        = "terraform-google-modules/service-accounts/google"
  version       = "4.6.0"
  project_id    = var.dev-project-id
  names         = ["terraform-cloud"]
  generate_keys = true
  project_roles = [
    "${var.dev-project-id}=>roles/owner"
  ]
}

module "service_account_qa" {
  #checkov:skip=CKV_TF_1:Using Terraform Registry with semantic versioning is acceptable for this module
  source        = "terraform-google-modules/service-accounts/google"
  version       = "4.6.0"
  project_id    = var.qa-project-id
  names         = ["terraform-cloud"]
  generate_keys = true
  project_roles = [
    "${var.qa-project-id}=>roles/owner"
  ]
}

module "service_account_stage" {
  #checkov:skip=CKV_TF_1:Using Terraform Registry with semantic versioning is acceptable for this module
  source        = "terraform-google-modules/service-accounts/google"
  version       = "4.6.0"
  project_id    = var.stage-project-id
  names         = ["terraform-cloud"]
  generate_keys = true
  project_roles = [
    "${var.stage-project-id}=>roles/owner"
  ]
}

module "service_account_prod" {
  #checkov:skip=CKV_TF_1:Using Terraform Registry with semantic versioning is acceptable for this module
  source        = "terraform-google-modules/service-accounts/google"
  version       = "4.6.0"
  project_id    = var.prod-project-id
  names         = ["terraform-cloud"]
  generate_keys = true
  project_roles = [
    "${var.prod-project-id}=>roles/owner"
  ]
}