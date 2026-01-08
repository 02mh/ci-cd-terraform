resource "tfe_workspace" "dev" {
  name                  = "app-dev"
  organization          = var.tf_cloud_organization
  tag_names             = ["cicd-terraform", "dev"]
  working_directory     = "infra"
  allow_destroy_plan    = true
  auto_apply            = true
  queue_all_runs        = false
  file_triggers_enabled = false
  vcs_repo {
    identifier     = var.vcs-identifier
    branch         = var.dev-main-branch
    oauth_token_id = var.github_oauth_token
  }
  description = "Terraform Cloud workspace for provisioning and managing the app-dev environment."
}

resource "tfe_workspace" "qa" {
  name                  = "app-qa"
  organization          = var.tf_cloud_organization
  tag_names             = ["cicd-terraform", "qa"]
  working_directory     = "infra"
  allow_destroy_plan    = true
  auto_apply            = true
  queue_all_runs        = false
  file_triggers_enabled = false
  vcs_repo {
    identifier     = var.vcs-identifier
    branch         = var.qa-main-branch
    oauth_token_id = var.github_oauth_token
  }
  description = "Terraform Cloud workspace for provisioning and managing the app-qa environment."
}

resource "tfe_workspace" "stage" {
  name                  = "app-stage"
  organization          = var.tf_cloud_organization
  tag_names             = ["cicd-terraform", "stage"]
  working_directory     = "infra"
  allow_destroy_plan    = true
  auto_apply            = true
  queue_all_runs        = false
  file_triggers_enabled = false
  vcs_repo {
    identifier     = var.vcs-identifier
    branch         = var.stage-main-branch
    oauth_token_id = var.github_oauth_token
  }
  description = "Terraform Cloud workspace for provisioning and managing the app-stage environment."
}

resource "tfe_workspace" "prod" {
  name                  = "app-prod"
  organization          = var.tf_cloud_organization
  tag_names             = ["cicd-terraform", "prod"]
  working_directory     = "infra"
  allow_destroy_plan    = true # Would not in real production environment; change, plan and apply
  auto_apply            = true
  queue_all_runs        = false
  file_triggers_enabled = false
  vcs_repo {
    identifier     = var.vcs-identifier
    branch         = var.prod-main-branch
    oauth_token_id = var.github_oauth_token
  }
  description = "Terraform Cloud workspace for provisioning and managing the app-prod environment."
}