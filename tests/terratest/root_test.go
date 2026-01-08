package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformRootModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../infra",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project-id":         "test-project",
			"region":             "us-central1",
			"zone":               "us-central1-a",
			"target_environment": "DEV",
		},

		// Environment variables to set when running terraform
		EnvVars: map[string]string{
			"GOOGLE_CLOUD_PROJECT": "test-project",
		},
	})

	// At the end of the test, run 'terraform destroy' to clean up any resources that were created
	// defer terraform.Destroy(t, terraformOptions)

	// This will run 'terraform init' and 'terraform plan' and fail the test if there are any errors
	terraform.InitAndPlan(t, terraformOptions)

	// If we wanted to actually deploy and verify:
	// terraform.InitAndApply(t, terraformOptions)
	// outputs := terraform.OutputAll(t, terraformOptions)
	// assert.NotNil(t, outputs["nginx-public-ip"])
}
