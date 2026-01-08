#!/usr/bin/env python3
"""
Generates terraform.tfvars.json based on the variables defined in infra/variables.tf.
"""
from dataclasses import dataclass, field
from typing import Dict, Any
import json

@dataclass
class TfVars:
    project_id_map: Dict[str, str]
    region: str = "us-central1"
    zone: str = "us-central1-a"
    prefix: str = "web"
    # Matches the map(object({machine_type=string, labels=map(string)})) in variables.tf
    server_settings: Dict[str, Any] = field(default_factory=lambda: {
        "web-server-1": {
            "machine_type": "e2-medium",
            "labels": {"env": "dev", "role": "web"}
        }
    })
    # Matches the object({network=string, subnetwork=string}) in variables.tf
    network_interface: Dict[str, str] = field(default_factory=lambda: {
        "network": "default",
        "subnetwork": "default"
    })

    def to_hcl(self):
        """Generates HCL format string for .tfvars file"""
        hcl_lines = []
        for key, value in self.__dict__.items():
            if isinstance(value, dict):
                hcl_lines.append(f"{key} = {json.dumps(value, indent=2)}")
            else:
                hcl_lines.append(f'{key} = "{value}"')
        return "\n".join(hcl_lines)

def write_tfvars(env_name: str, tfvars_obj: TfVars):
    filename = f"infra/{env_name}.auto.tfvars"
    with open(filename, "w") as f:
        f.write(tfvars_obj.to_hcl())
    print(f"Created {filename}")

if __name__ == "__main__":
    print("__Terraform Variables Generator__")
    print("\nThis script generates .tfvars files for your environments.")
    print("You'll need to provide configuration for each environment.\n")

    # Collect project information
    dev_project = input("Enter GCP DEV Project ID: ")
    qa_project = input("Enter GCP QA Project ID: ")
    stage_project = input("Enter GCP STAGE Project ID: ")
    prod_project = input("Enter GCP PROD Project ID: ")
    region = input("Enter GCP Region (default: us-central1): ") or "us-central1"
    zone = input("Enter GCP Zone (default: us-central1-a): ") or "us-central1-a"

    # Create tfvars for main infrastructure
    main_tfvars = TfVars(
        project_id_map={
            "DEV": dev_project,
            "QA": qa_project,
            "STAGE": stage_project,
            "PROD": prod_project
        },
        region=region,
        zone=zone
    )

    write_tfvars("main", main_tfvars)
    print("\nVariable files generated successfully!")
    print("Review the generated files in the infra/ directory before running terraform.")