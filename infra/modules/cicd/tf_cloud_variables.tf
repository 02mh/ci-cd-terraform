resource "tfe_variable" "dev_project_id" {
  key          = "project-id"
  value        = var.dev-project-id
  category     = "terraform"
  workspace_id = tfe_workspace.dev.id
  description  = "DEV GCP Project ID"
}

resource "tfe_variable" "qa_project_id" {
  key          = "project-id"
  value        = var.qa-project-id
  category     = "terraform"
  workspace_id = tfe_workspace.qa.id
  description  = "QA GCP Project ID"
}

resource "tfe_variable" "stage_project_id" {
  key          = "project-id"
  value        = var.stage-project-id
  category     = "terraform"
  workspace_id = tfe_workspace.stage.id
  description  = "STAGE GCP Project ID"
}

resource "tfe_variable" "prod_project_id" {
  key          = "project-id"
  value        = var.prod-project-id
  category     = "terraform"
  workspace_id = tfe_workspace.prod.id
  description  = "PROD GCP Project ID"
}

resource "tfe_variable" "dev_target_environment" {
  key          = "target_environment"
  value        = "DEV"
  category     = "terraform"
  workspace_id = tfe_workspace.dev.id
  description  = "DEV Target Environment"
}

resource "tfe_variable" "qa_target_environment" {
  key          = "target_environment"
  value        = "QA"
  category     = "terraform"
  workspace_id = tfe_workspace.qa.id
  description  = "QA Target Environment"
}

resource "tfe_variable" "stage_target_environment" {
  key          = "target_environment"
  value        = "STAGE"
  category     = "terraform"
  workspace_id = tfe_workspace.stage.id
  description  = "STAGE Target Environment"
}

resource "tfe_variable" "prod_target_environment" {
  key          = "target_environment"
  value        = "PROD"
  category     = "terraform"
  workspace_id = tfe_workspace.prod.id
  description  = "PROD Target Environment"
}

resource "tfe_variable" "dev_google_credentials" {
  key          = "GOOGLE_CREDENTIALS"
  value        = replace(module.service_account_dev.key, "/\\n/", "")
  category     = "env"
  workspace_id = tfe_workspace.dev.id
  sensitive    = true
  description  = "DEV Project Credentials"
}

resource "tfe_variable" "qa_google_credentials" {
  key          = "GOOGLE_CREDENTIALS"
  value        = replace(module.service_account_qa.key, "/\\n/", "")
  category     = "env"
  workspace_id = tfe_workspace.qa.id
  sensitive    = true
  description  = "QA Project Credentials"
}

resource "tfe_variable" "stage_google_credentials" {
  key          = "GOOGLE_CREDENTIALS"
  value        = replace(module.service_account_stage.key, "/\\n/", "")
  category     = "env"
  workspace_id = tfe_workspace.stage.id
  sensitive    = true
  description  = "STAGE Project Credentials"
}

resource "tfe_variable" "prod_google_credentials" {
  key          = "GOOGLE_CREDENTIALS"
  value        = replace(module.service_account_prod.key, "/\\n/", "")
  category     = "env"
  workspace_id = tfe_workspace.prod.id
  sensitive    = true
  description  = "PROD Project Credentials"
}

resource "tfe_variable" "dev_project_id_map" {
  key = "project_id_map"
  value = jsonencode({
    DEV   = var.dev-project-id
    QA    = var.qa-project-id
    STAGE = var.stage-project-id
    PROD  = var.prod-project-id
  })
  category     = "terraform"
  workspace_id = tfe_workspace.dev.id
  hcl          = true
  description  = "Mapping of environments to GCP Project IDs"
}

resource "tfe_variable" "qa_project_id_map" {
  key = "project_id_map"
  value = jsonencode({
    DEV   = var.dev-project-id
    QA    = var.qa-project-id
    STAGE = var.stage-project-id
    PROD  = var.prod-project-id
  })
  category     = "terraform"
  workspace_id = tfe_workspace.qa.id
  hcl          = true
  description  = "Mapping of environments to GCP Project IDs"
}

resource "tfe_variable" "stage_project_id_map" {
  key = "project_id_map"
  value = jsonencode({
    DEV   = var.dev-project-id
    QA    = var.qa-project-id
    STAGE = var.stage-project-id
    PROD  = var.prod-project-id
  })
  category     = "terraform"
  workspace_id = tfe_workspace.stage.id
  hcl          = true
  description  = "Mapping of environments to GCP Project IDs"
}

resource "tfe_variable" "prod_project_id_map" {
  key = "project_id_map"
  value = jsonencode({
    DEV   = var.dev-project-id
    QA    = var.qa-project-id
    STAGE = var.stage-project-id
    PROD  = var.prod-project-id
  })
  category     = "terraform"
  workspace_id = tfe_workspace.prod.id
  hcl          = true
  description  = "Mapping of environments to GCP Project IDs"
}