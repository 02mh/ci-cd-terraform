package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformWebserverModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../infra/modules/webservers",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_id": "test-project",
			"region":     "us-central1",
			"zone":       "us-central1-a",
			"server_settings": map[string]interface{}{
				"server1": map[string]interface{}{
					"machine_type": "e2-medium",
					"labels": map[string]string{
						"environment": "test",
					},
				},
			},
			"network_interface": map[string]interface{}{
				"network":    "default",
				"subnetwork": "default",
			},
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
	// webserverIPs := terraform.OutputList(t, terraformOptions, "webserver-ips")
	// assert.NotEmpty(t, webserverIPs)
}
