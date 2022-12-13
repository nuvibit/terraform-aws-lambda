package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambdaSNS(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting lambda module SNS test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/lambda-sns",
		NoColor:      false,
		Lock:         true,
		Vars: map[string]interface{}{
			"function_name": "test_lambda_sns",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Do testing. I.E check if your ressources are deployed via AWS GO SDK


	lambdaArn := terraform.Output(t, terraformOptions, "lambda_arn")
	if strings.Contains(lambdaArn, "test_lambda_sns") {
		t.Log("PASSED: lambda_arn contains \"test_lambda_sns\"")
	} else {
		t.Errorf("FAILED: expected lambda_arn to contain \"test_lambda_sns\"")
	}
}
