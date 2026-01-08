terraform {
  cloud {
    organization = "M2-HHA" # Update with applicable Organization Name
    hostname     = "app.terraform.io"

    workspaces {
      tags = ["cicd-terraform"] # Tag-based workspace selection
      # The actual workspace will be selected based on TF_WORKSPACE environment variable
      # or by using `terraform workspace select <workspace-name>`
      # Available workspaces: app-dev, app-qa, app-stage, app-prod
    }
  }
}