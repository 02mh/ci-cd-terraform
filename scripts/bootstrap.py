#!/usr/bin/env python3
"""
Initializes the CI/CD Terraform environment for GCP by validating dependencies,
creating backend configuration, and preparing workspace directories.
"""
import os
import subprocess
import sys

def check_authentication():
    """Verify GCP authentication is configured"""
    print("\n--- Checking GCP Authentication ---")
    try:
        result = subprocess.run(
            ["gcloud", "auth", "application-default", "print-access-token"],
            capture_output=True,
            text=True,
            check=False,
            shell=True
        )
        if result.returncode != 0:
            print("\nGCP authentication not configured!")
            print("Please run: gcloud auth application-default login")
            print("Then re-run this script.\n")
            sys.exit(1)
        print("✓ GCP authentication verified")
    except FileNotFoundError:
        print("\nGCloud CLI not found!")
        print("Please install Google Cloud SDK: https://cloud.google.com/sdk/docs/install")
        sys.exit(1)

def check_terraform():
    """Verify Terraform is installed"""
    print("\n--- Checking Terraform Installation ---")
    try:
        result = subprocess.run(
            ["terraform", "version"],
            capture_output=True,
            text=True,
            check=True
        )
        print(f"✓ Terraform installed: {result.stdout.split()[1]}")
    except FileNotFoundError:
        print("\nTerraform not found!")
        print("Please install Terraform: https://www.terraform.io/downloads.html")
        sys.exit(1)

def run_bootstrap():
    print("=" * 60)
    print("  GCP CI/CD Bootstrapper")
    print("=" * 60)

    # Check prerequisites
    check_terraform()
    check_authentication()

    # Store original directory
    original_dir = os.getcwd()

    print("\n--- Collecting Configuration ---")
    # 1. Collect inputs for the CICD module
    config = {
        "tf_cloud_organization": input("Enter TFE Organization: "),
        "tf_cloud_token": input("Enter TFE Token (from https://app.terraform.io/app/settings/tokens): "),
        "github_oauth_token": input("Enter OAuth Token ID (from TFC org settings > VCS Providers): "),
        "dev-project-id": input("Enter GCP DEV Project ID: "),
        "qa-project-id": input("Enter GCP QA Project ID: "),
        "stage-project-id": input("Enter GCP STAGE Project ID: "),
        "prod-project-id": input("Enter GCP PROD Project ID: "),
        "vcs-identifier": input("Enter Repo (org/repo): "),
        "dev-main-branch": input("Enter DEV branch name (default: dev): ") or "dev",
        "qa-main-branch": input("Enter QA branch name (default: qa): ") or "qa",
        "stage-main-branch": input("Enter STAGE branch name (default: stage): ") or "stage",
        "prod-main-branch": input("Enter PROD branch name (default: main): ") or "main"
    }

    # 2. Generate the CICD module's tfvars
    print("\n--- Creating CICD Module Configuration ---")
    cicd_vars_path = os.path.join(original_dir, "infra/modules/cicd/terraform.tfvars")
    with open(cicd_vars_path, "w") as f:
        for k, v in config.items():
            f.write(f'{k} = "{v}"\n')
    print(f"✓ Created {cicd_vars_path}")

    # 3. Initialize and Apply CICD module
    print("\n--- Deploying CICD Infrastructure ---")
    print("This will create Terraform Cloud workspaces and GCP service accounts...")
    cicd_dir = os.path.join(original_dir, "infra/modules/cicd")
    os.chdir(cicd_dir)

    # Set up environment variables for Terraform
    tf_env = os.environ.copy()
    tf_env["TF_TOKEN_app_terraform_io"] = config["tf_cloud_token"]

    print("\nRunning: terraform init")
    subprocess.run(["terraform", "init"], check=True, env=tf_env)

    print("\nRunning: terraform apply")
    subprocess.run(["terraform", "apply", "-auto-approve"], check=True, env=tf_env)

    # 4. Return to original directory
    os.chdir(original_dir)

    # 5. Generate main infrastructure variables
    print("\n--- Generating Main Infrastructure Variables ---")
    print("Now configuring the main infrastructure deployment...")

    region = input("\nEnter GCP Region (default: us-central1): ") or "us-central1"
    zone = input("Enter GCP Zone (default: us-central1-a): ") or "us-central1-a"
    org_id = input("Enter GCP Organization ID (optional, press Enter to skip): ")

    main_tfvars_path = os.path.join(original_dir, "infra/terraform.tfvars")
    with open(main_tfvars_path, "w") as f:
        f.write('project_id_map = {\n')
        f.write(f'  "DEV"   = "{config["dev-project-id"]}"\n')
        f.write(f'  "QA"    = "{config["qa-project-id"]}"\n')
        f.write(f'  "STAGE" = "{config["stage-project-id"]}"\n')
        f.write(f'  "PROD"  = "{config["prod-project-id"]}"\n')
        f.write('}\n')
        f.write(f'region = "{region}"\n')
        f.write(f'zone = "{zone}"\n')
        if org_id:
            f.write(f'org_id = "{org_id}"\n')
    print(f"✓ Created {main_tfvars_path}")

    # 6. Initialize main infrastructure
    print("\n--- Initializing Main Infrastructure ---")
    infra_dir = os.path.join(original_dir, "infra")
    os.chdir(infra_dir)

    print("\nRunning: terraform init")
    subprocess.run(["terraform", "init"], check=True, env=tf_env)

    os.chdir(original_dir)

    # 7. Success message
    print("\n" + "=" * 60)
    print("  Bootstrap Complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Navigate to the infra directory: cd infra")
    print("2. Initialize Terraform: terraform init")
    print("3. Select your environment workspace (e.g., dev):")
    print("   terraform workspace select app-dev")
    print("4. Plan and deploy your infrastructure:")
    print("   terraform plan")
    print("   terraform apply (Note, you need to perform a git action to tf apply, since we have VCS-driven workspaces)")
    print("\nYour Terraform Cloud workspaces are now configured and mapped to your local environments!")

if __name__ == "__main__":
    try:
        run_bootstrap()
    except KeyboardInterrupt:
        print("\n\n⚠️  Bootstrap cancelled by user")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"\n\n❌ Error running command: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Unexpected error: {e}")
        sys.exit(1)