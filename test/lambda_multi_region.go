package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambdaMultiRegion(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting lambda module test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/lambda-multi-region",
		NoColor:      false,
		Lock:         true,
		Vars: map[string]interface{}{
			"function_name": "test_lambda",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Do testing. I.E check if your ressources are deployed via AWS GO SDK
    
	time.Sleep(60 * time.Second)


	lambda_Arn := terraform.Output(t, terraformOptions, "lambda_arn")
	if strings.Contains(lambda_Arn, "test_lambda") {
		t.Log("PASSED: lambda_arn contains \"test_lambda\"")
	} else {
		t.Errorf("FAILED: expected lambda_arn to contain \"test_lambda\"")
	}

}
