### BUCKETS
#tfsec:ignore:google-storage-bucket-encryption-customer-key - Using Google-managed encryption is acceptable for demo environment
resource "google_storage_bucket" "environment_bucket" {
  #checkov:skip=CKV_GCP_62:Access logging not required for demo environment; avoiding additional infrastructure and costs
  name                        = local.project_id
  project                     = local.project_id
  location                    = "US"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = {
    environment = var.environment_map[local.env]
  }
}