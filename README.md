# GCP CI/CD Template

This repository provides a template for managing Google Cloud Platform (GCP) infrastructure using Terraform, integrated with Terraform Cloud for CI/CD. It includes helper scripts to bootstrap the environment and manage configuration.

## Overview

The project is designed to automate the deployment of GCP resources (Networking, Compute, Storage, etc.) across multiple environments (DEV, QA, STAGE, PROD) using a modular Terraform approach.

## Stack

- **Cloud Provider:** Google Cloud Platform (GCP)
- **Infrastructure as Code:** Terraform
- **Backend:** Terraform Cloud (TFE)
- **Scripting:** Python 3
- **CI/CD:** GitHub Actions for PR validation and Terraform Cloud (TFE) for deployments

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0.0)
- [Python 3.x](https://www.python.org/downloads/)
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install)
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for pre-commit)
- [Trivy](https://github.com/aquasecurity/trivy) (optional, for pre-commit - currently disabled for Windows ARM-64)
- [Terratest](https://terratest.gruntwork.io/) (for integration testing)
- [Go](https://golang.org/dl/) (>= 1.13, for Terratest)
- [GitHub Actions](https://github.com/features/actions) (for CI)
- [Docker](https://www.docker.com/products/docker-desktop/) (optional, for containerized development)
- A Google Cloud Platform account and project
- A Terraform Cloud account

## Project Structure

```text
.
├── infra/                  # Main Terraform configuration
│   ├── modules/            # Reusable Terraform modules
│   │   ├── cicd/           # Module for setting up TFE workspaces and GCP service accounts
│   │   └── webservers/     # Module for web server instances
│   ├── backend.tf          # Terraform Cloud backend configuration
│   ├── main.tf             # Main resource definitions
│   ├── variables.tf        # Global variables
│   └── ...
├── scripts/                # Helper Python scripts
│   ├── bootstrap.py        # Initializes the CI/CD environment
│   └── generate_tfvars.py  # Generates .tfvars files from Python dataclasses
├── tests/                  # Infrastructure tests
│   └── terratest/          # Terratest (Go-based) integration tests
├── .pre-commit-config.yaml # Pre-commit configuration
├── Dockerfile              # Containerized development environment
├── requirements.txt        # Python dependencies
└── README.md               # Project documentation
```

## Prerequisites

Before running the bootstrap script, ensure you have:

1. **Installed Required Tools:**
   - [Terraform](https://www.terraform.io/downloads.html) (>= 1.0.0)
   - [Python 3.x](https://www.python.org/downloads/)
   - [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install)

2. **Configured GCP Authentication:**
   ```bash
   gcloud auth application-default login
   ```

3. **Created GCP Resources via Console:**
   - GCP Organization (note the Organization ID)
   - GCP Projects for DEV, QA, STAGE, and PROD environments
   - Billing account linked to your projects

4. **Created Terraform Cloud Resources:**
   - A Terraform Cloud account and organization
   - An API token (User Settings → Tokens → Create an API token)
   - A GitHub VCS Provider connection configured in your organization (Settings → VCS Providers)

5. **Configured GitHub Integration:**
   - GitHub repository created for this project
   - Note the OAuth Token ID from your TFC VCS Provider (format: `ot-XXXXXXXXXX`)

## Setup & Installation

### Step 1: Authenticate with GCP

Ensure you're authenticated with GCP before proceeding:

```bash
gcloud auth application-default login
```

The bootstrap script will verify this authentication before proceeding.

### Step 2: Run the Bootstrap Script

The `bootstrap.py` script is the primary setup tool that:
- Validates prerequisites (Terraform, GCP authentication)
- Creates Terraform Cloud workspaces
- Deploys CI/CD infrastructure
- Generates main infrastructure variables
- Initializes Terraform for main infrastructure deployment

Run the bootstrap script from the project root:

```bash
python scripts/bootstrap.py
```

The script will prompt you for:

**CI/CD Configuration:**
- Terraform Cloud Organization name
- Terraform Cloud API Token (from https://app.terraform.io/app/settings/tokens)
- OAuth Token ID from TFC VCS Provider (from your org's Settings → VCS Providers, format: `ot-XXXXXXXXXX`)
- GCP DEV Project ID
- GCP QA Project ID
- GCP STAGE Project ID
- GCP PROD Project ID
- Repository identifier (format: `org/repo`)
- DEV branch name (default: `dev`)
- QA branch name (default: `qa`)
- STAGE branch name (default: `stage`)
- PROD branch name (default: `main`)

**Main Infrastructure Configuration:**
- GCP Region (default: `us-central1`)
- GCP Zone (default: `us-central1-a`)
- GCP Organization ID (optional)

The bootstrap script will automatically:
1. Create `infra/modules/cicd/terraform.tfvars` with CI/CD configuration
2. Deploy the CICD module to create Terraform Cloud workspaces
3. Create `infra/terraform.tfvars` with main infrastructure variables, including the mapping of all environments to their respective project IDs.
4. Initialize Terraform in the `infra` directory

### Step 3: Select Workspace and Deploy Main Infrastructure

After the bootstrap script completes successfully, select the workspace for the environment you want to target:

```bash
cd infra
terraform workspace select app-dev
terraform plan
terraform apply
```

Review the plan carefully before applying to ensure all resources are configured as expected.

## Usage

### Working with Multiple Environments

This project uses separate Terraform Cloud workspaces for each environment (DEV, QA, STAGE, PROD). Each workspace maintains its own state file, ensuring environment isolation.

**Selecting a Workspace:**

Before running Terraform commands locally, select the appropriate workspace. The project is configured to automatically map the selected workspace to the correct GCP Project ID and environment settings.

```bash
cd infra
terraform workspace select app-dev     # For DEV environment
terraform workspace select app-qa      # For QA environment
terraform workspace select app-stage   # For STAGE environment
terraform workspace select app-prod    # For PROD environment
```

Alternatively, set the `TF_WORKSPACE` environment variable:

```bash
export TF_WORKSPACE=app-dev    # Linux/Mac
set TF_WORKSPACE=app-dev       # Windows CMD
$env:TF_WORKSPACE="app-dev"    # Windows PowerShell
```

**Listing Available Workspaces:**

```bash
terraform workspace list
```

### Deploying Infrastructure Changes

After selecting the appropriate workspace, you can make changes to your infrastructure:

```bash
cd infra
terraform workspace select app-dev  # Select your target environment
terraform plan          # Review proposed changes
terraform apply         # Apply changes
```

### Dynamic Configuration Selection

The project uses `terraform.workspace` to dynamically determine the target environment and project ID. This logic is defined in `infra/main.tf` under the `locals` block:

- `app-dev` -> `DEV` environment
- `app-qa`  -> `QA` environment
- `app-stage` -> `STAGE` environment
- `app-prod` -> `PROD` environment

If you are running in Terraform Cloud, the `target_environment` and `project-id` variables are set automatically via the workspace variables. Locally, the workspace selection takes precedence.

### Alternative: Generate Variables Manually

If you need to regenerate variable files or prefer manual configuration, you can use the `generate_tfvars.py` script:

```bash
python scripts/generate_tfvars.py
```

This script will prompt you for GCP configuration and generate `infra/main.auto.tfvars`. (Note: The bootstrap script also generates `infra/terraform.tfvars` for the initial run.)

### Containerized Development (Optional)

You can use the provided `Dockerfile` to run the project in a consistent environment with all dependencies (Terraform, gcloud, Go, Python) pre-installed.

**Build the image:**
```bash
docker build -t cicd-terraform .
```

**Run the container:**
```bash
docker run -it --rm -v ${PWD}:/app cicd-terraform
```

### CI/CD Workflow

Once the bootstrap process is complete, your CI/CD pipeline works as follows:

1. **Initial Setup:** The `bootstrap.py` script has already created Terraform Cloud workspaces linked to your GitHub repository
   - `app-dev` - DEV environment workspace
   - `app-qa` - QA environment workspace
   - `app-stage` - STAGE environment workspace
   - `app-prod` - PROD environment workspace

2. **PR Validation:** When you create a Pull Request to `main`, `dev`, `qa`, or `stage` branches, a GitHub Action triggers to:
   - Check Terraform formatting (`terraform fmt`)
   - Initialize Terraform (`terraform init -backend=false`)
   - Validate Terraform configuration (`terraform validate`)

3. **Development:** Create feature branches for your infrastructure changes

4. **Automated Runs:** Push commits to trigger Terraform Cloud runs:
   - Push to `dev` branch → triggers `app-dev` workspace
   - Push to `qa` branch → triggers `app-qa` workspace
   - Push to `stage` branch → triggers `app-stage` workspace
   - Push to `main` branch → triggers `app-prod` workspace

5. **Review & Apply:** Review the Terraform plan in Terraform Cloud and approve to apply changes

**Important Notes:**
- Each workspace maintains its own separate state file
- Workspaces are isolated to prevent accidental changes across environments
- Configure environment-specific variables in each Terraform Cloud workspace
- Use the `target_environment` variable to control environment-specific behavior

## Configuration Files

The bootstrap process creates the following configuration files:

### Generated by Bootstrap Script

- **`infra/modules/cicd/terraform.tfvars`** - CI/CD module configuration
  - Contains Terraform Cloud credentials and workspace settings
  - Used to create TF Cloud workspaces and GCP service accounts

- **`infra/terraform.tfvars`** - Main infrastructure variables
  - Contains GCP project, region, zone, and org ID
  - Used for deploying the main infrastructure resources

### Manual Configuration

- **`infra/backend.tf`** - Terraform Cloud backend configuration
  - Update the `organization` field with your TF Cloud org name
  - Configured to use tag-based workspace selection for multi-environment support
  - Each environment (DEV, QA, STAGE, PROD) uses a separate Terraform Cloud workspace

## Variable Reference

### CI/CD Module Variables (infra/modules/cicd/variables.tf)

| Variable | Description                                                    | Required |
|----------|----------------------------------------------------------------|----------|
| `tf_cloud_organization` | Terraform Cloud organization name                              | Yes |
| `tf_cloud_token` | Terraform Cloud API token                                      | Yes |
| `github_oauth_token` | OAuth Token ID from TFC VCS Provider (format: `ot-XXXXXXXXXX`) | Yes |
| `dev-project-id` | GCP Project ID for DEV environment                             | Yes |
| `qa-project-id` | GCP Project ID for QA environment                              | Yes |
| `stage-project-id` | GCP Project ID for STAGE environment                           | Yes |
| `prod-project-id` | GCP Project ID for PROD environment                            | Yes |
| `vcs-identifier` | Repository in format `org/repo`                                | Yes |
| `dev-main-branch` | Git branch for DEV (default: dev)                              | No |
| `qa-main-branch` | Git branch for QA (default: qa)                                | No |
| `stage-main-branch` | Git branch for STAGE (default: stage)                          | No |
| `prod-main-branch` | Git branch for PROD (default: main)                            | No |

### Main Infrastructure Variables (infra/variables.tf)

| Variable | Description                                              | Default                          |
|----------|----------------------------------------------------------|----------------------------------|
| `project-id` | GCP Project ID                                           | -                                |
| `gcp_credentials` | Path to the GCP service account key file (optional)      | -                                |
| `org_id` | GCP Organization ID (optional)                           | -                                |
| `region` | GCP Region                                               | us-central1                      |
| `zone` | GCP Zone                                                 | us-central1-a                    |
| `subnet-name` | Name of the subnet to create or use                      | subnet1                          |
| `subnet-cidr` | CIDR range for the subnet                                | 10.127.0.0/20                    |
| `private_google_access` | Enables Private Google Access                            | true                             |
| `firewall-ports` | List of ports or port ranges to allow                    | ["80", "8080", "1000-2000", "22"] |
| `compute-source-tags` | Network tags for firewall rule targeting                 | ["web"]                          |
| `project_id_map` | Mapping of environments to GCP Project IDs               | (see variables.tf)                                 |
| `target_environment` | Target environment for deployment (DEV, QA, STAGE, PROD) | DEV                              |
| `environment_list` | List of valid deployment environments                    | ["DEV","QA","STAGE","PROD"]      |
| `environment_map` | Map of environment names to short codes                  | (see variables.tf)               |
| `environment_machine_type` | Mapping of environments to compute machine types         | (see variables.tf)               |
| `environment_instance_settings` | Per-environment instance settings (machine type, labels) | (see variables.tf)               |

## Security Considerations

This project implements security best-practices while maintaining practical functionality for a demo/learning environment:

### Implemented Security Features
- **Shielded VM:** All compute instances use Shielded VMs with VTPM and integrity monitoring enabled
- **SSH Key Management:** Project-wide SSH keys are blocked; instance-specific keys required
- **Bucket Access Control:** Uniform bucket-level access and public access prevention enabled for simplified IAM management
- **Network Monitoring:** VPC flow logs enabled for network traffic auditing
- **Module Version Pinning:** Terraform modules pinned to specific versions for supply chain security

### Accepted Security Trade-offs
The following security findings have been acknowledged and accepted for this demo environment:

- **Public Internet Access:** Firewall rules allow public ingress for demo/testing purposes
  - *Production recommendation:* Restrict source IP ranges or use Cloud Armor/Load Balancer

- **Public IP on Nginx Instance:** Nginx proxy has a public IP for external access
  - *Production recommendation:* Remove public IP and use Cloud Load Balancer with Cloud NAT

- **Google-Managed Encryption:** Using Google-managed encryption keys instead of customer-managed keys (CMEK)
  - *Production recommendation:* Implement Cloud KMS with customer-managed keys for compliance requirements

- **Bucket Access Logging:** Storage bucket access logging disabled to minimize demo infrastructure complexity
  - *Production recommendation:* Enable access logging to a dedicated log bucket for audit trails

These trade-offs prioritize ease of use and cost-effectiveness for learning environments. For production deployments, review the GitHub Actions security scan outputs (Trivy/Checkov) and implement additional hardening as needed.

## Troubleshooting

### Authentication Issues

**Problem:** `GCP authentication not configured` or `google: could not find default credentials` error

**Solution:**
1. **Application Default Credentials (Recommended):**
   ```bash
   gcloud auth application-default login
   ```
2. **Service Account Key File:**
   If you prefer using a service account key, you can provide the path to the JSON file:
   - Via variable: `terraform plan -var="gcp_credentials=path/to/key.json"`
   - Via environment variable: `export TF_VAR_gcp_credentials=path/to/key.json`
   - Via `terraform.tfvars`: Add `gcp_credentials = "path/to/key.json"`

### Terraform Not Found

**Problem:** `Terraform not found` error

**Solution:** Install Terraform from [terraform.io/downloads](https://www.terraform.io/downloads.html) and ensure it's in your PATH

### Backend Configuration

**Problem:** Backend initialization fails for main infrastructure

**Solution:** Ensure you've updated `infra/backend.tf` with your Terraform Cloud organization name before running the bootstrap script

### Module Errors

**Problem:** Errors when applying CICD module

**Solution:**
- Verify all required variables are provided correctly
- Ensure your Terraform Cloud token has adequate permissions
- Check that GCP projects exist and are accessible

## Quick Start Summary

For a complete end-to-end setup:

```bash
# 1. Authenticate with GCP
gcloud auth application-default login

# 2. Run bootstrap script (from project root)
python scripts/bootstrap.py

# 3. Deploy infrastructure
cd infra
terraform plan
terraform apply
```

## What Gets Deployed

After successful execution, the following resources are created:

### CI/CD Infrastructure (via bootstrap)
- Terraform Cloud workspaces (DEV, QA, STAGE, PROD)
- GCP Service Accounts for CI/CD
- Workspace variables and VCS connections

### Main Infrastructure (via terraform apply)

Each environment deploys resources to its own isolated GCP project:

**Per Environment (DEV, QA, STAGE, PROD):**
- **Compute Instances:**
  - `{env}-nginx-proxy` - NGINX reverse proxy server
  - `{env}-web-server` - Application web server
  - `{env}-mysqldb` - MySQL database server
- **Networking:**
  - `{env}-subnet1` - VPC subnet
  - `{env}-firewall` - Firewall rules
- **Storage:**
  - `{project-id}` - GCS bucket (e.g., cicdterraform-dev, cicdterraform-qa)
- **Service Accounts:**
  - `{env}-viewer-sa-app` - Service account with viewer permissions

**Example for DEV environment in cicdterraform-dev project:**
- dev-nginx-proxy
- dev-web-server
- dev-mysqldb
- dev-subnet1
- dev-firewall
- cicdterraform-dev (bucket)
- dev-viewer-sa-app

Each workspace creates resources only for its specific environment, ensuring complete isolation between DEV, QA, STAGE, and PROD.

## Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to ensure code quality. The `terraform_fmt` and `terraform_validate` hooks are enabled and configured to use the Terraform binary at `C:/infra/tools/terraform/terraform.exe`. Other hooks remain disabled by default.

The hooks include:
- `terraform_fmt`: Formats Terraform files.
- `terraform_validate`: Validates Terraform configuration.
- `terraform_tflint`: Runs [TFLint](https://github.com/terraform-linters/tflint) for best practices (currently disabled).
- `terraform_trivy`: Runs [Trivy](https://github.com/aquasecurity/trivy) for security (currently disabled for Windows ARM-64 compatibility).

### How to Resolve Commit Errors
If you encounter `exit code 127` or "command not found" errors during commit, it means pre-commit is trying to run tools that are not in your `PATH`. We have commented these out in `.pre-commit-config.yaml` to allow you to proceed.

### Enabling Hooks
To enable these checks, ensure you have the required binaries installed and then uncomment the respective lines in `.pre-commit-config.yaml`.

1. **Install Required Tools:**
   - [Terraform](https://www.terraform.io/downloads.html)
   - [TFLint](https://github.com/terraform-linters/tflint#installation)
   - [Trivy](https://aquasecurity.github.io/trivy/latest/getting-started/installation/) (Note: Trivy may not work on Windows ARM-64).

2. **Install pre-commit:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Install the git hook scripts:**
   ```bash
   pre-commit install
   ```

4. **Run against all files (Optional):**
   ```bash
   pre-commit run --all-files
   ```

## Testing

This project supports infrastructure testing using Terraform's native test framework and Terratest, as well as unit tests for Python helper scripts.

### Python Script Unit Tests

Unit tests for `scripts/bootstrap.py` and `scripts/generate_tfvars.py` are written using `pytest`.

**Prerequisites:**
```bash
pip install -r requirements.txt
```

**Running Tests:**
```bash
python -m pytest tests/scripts
```

### Native Terraform Testing

Uses the `terraform test` command introduced in Terraform 1.6. Tests are located in `tests` subdirectories within modules.

To run tests for the `webservers` module:
```bash
cd infra/modules/webservers
terraform test
```

To run tests for other modules (`cicd`, `webservers`):
```bash
cd infra/modules/<module_name>
terraform test
```

To run tests for the root infrastructure:
```bash
cd infra
terraform test
```

### Terratest (Go-based)

Terratest is used for more complex integration testing. Tests are located in the root `tests/terratest` directory.

**Prerequisites:**
- Go installed (>= 1.13)
- GCP credentials configured

**Running Terratest:**
```bash
cd tests/terratest
go mod init github.com/your-org/cicd-terraform-tests
go mod tidy
go test -v
```

Note: The provided Terratest example is configured to run `terraform init` and `terraform plan`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
