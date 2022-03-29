package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambda(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting lambda module test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/lambda",
		NoColor:      false,
		Lock:         true,
		Vars: map[string]interface{}{
			"function_name": "test_lambda",
		},
	}

	terraform.InitAndApply(t, terraformOptions)

	// Do testing. I.E check if your ressources are deployed via AWS GO SDK

	defer terraform.Destroy(t, terraformOptions)

	lambda_1_Arn := terraform.Output(t, terraformOptions, "lambda_1_arn")
	if strings.Contains(lambda_1_Arn, "test_lambda") {
		t.Log("PASSED: lambda_1_arn contains \"test_lambda\"")
	} else {
		t.Errorf("FAILED: expected lambda_1_arn to contain \"test_lambda\"")
	}

	lambda_2_Arn := terraform.Output(t, terraformOptions, "lambda_1_arn")
	if strings.Contains(lambda_2_Arn, "test_lambda") {
		t.Log("PASSED: lambda_2_arn contains \"test_lambda\"")
	} else {
		t.Errorf("FAILED: expected lambda_2_arn to contain \"test_lambda\"")
	}

}
