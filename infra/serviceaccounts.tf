### SERVICE ACCOUNTS
module "service_accounts" {
  #checkov:skip=CKV_TF_1:Using Terraform Registry with semantic versioning is acceptable for this module
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.6.0"
  project_id = local.project_id
  prefix     = "${var.environment_map[local.env]}-viewer-sa"
  names      = ["app"]
  project_roles = [
    "${local.project_id}=>roles/viewer",
    "${local.project_id}=>roles/storage.objectViewer",
  ]
  grant_billing_role = true
  org_id             = var.org_id
}