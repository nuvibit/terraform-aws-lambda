package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambdaMultiRegion(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting lambda module multi-region test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/lambda-multi-region",
		NoColor:      false,
		Lock:         true,
		Vars: map[string]interface{}{
			"function_name": "test_lambda_multi_region",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Do testing. I.E check if your ressources are deployed via AWS GO SDK
    
	lambda_euc1_Arn := terraform.Output(t, terraformOptions, "lambda_euc1_arn")
	if strings.Contains(lambda_euc1_Arn, "test_lambda_multi_region") {
		t.Log("PASSED: lambda_arn contains \"test_lambda_multi_region\"")
	} else {
		t.Errorf("FAILED: expected lambda_arn to contain \"test_lambda_multi_region\"")
	}

	lambda_euw1_Arn := terraform.Output(t, terraformOptions, "lambda_euw1_arn")
	if strings.Contains(lambda_euw1_Arn, "test_lambda_multi_region") {
		t.Log("PASSED: lambda_arn contains \"test_lambda_multi_region\"")
	} else {
		t.Errorf("FAILED: expected lambda_arn to contain \"test_lambda_multi_region\"")
	}

	lambda_use1_Arn := terraform.Output(t, terraformOptions, "lambda_use1_arn")
	if strings.Contains(lambda_use1_Arn, "test_lambda_multi_region") {
		t.Log("PASSED: lambda_arn contains \"test_lambda_multi_region\"")
	} else {
		t.Errorf("FAILED: expected lambda_arn to contain \"test_lambda_multi_region\"")
	}


}
