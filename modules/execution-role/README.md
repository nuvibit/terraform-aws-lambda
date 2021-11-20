# AWS IAM Execution Role Terraform sub-module

Terraform sub-module which creates IAM execution role for a lambda function on AWS.

## Usage
```hcl
module "execution_role" {
  source = "nuvibit/lambda/aws//modules/execution-role"

  iam_execution_role_name = "lambda-execution-role"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_execution_role"></a> [create\_execution\_role](#input\_create\_execution\_role) | Controls if IAM execution role resources should be created. | `bool` | `true` | no |
| <a name="input_iam_execution_policy_arns"></a> [iam\_execution\_policy\_arns](#input\_iam\_execution\_policy\_arns) | List of optional additional execution policy statement ARNs outside this module to attach to IAM Lambda execution role. | `list(string)` | `[]` | no |
| <a name="input_iam_execution_role_external_arn"></a> [iam\_execution\_role\_external\_arn](#input\_iam\_execution\_role\_external\_arn) | ARN of an optional external IAM execution role outside this module. If omitted, an execution role will be created. | `string` | `null` | no |
| <a name="input_iam_execution_role_name"></a> [iam\_execution\_role\_name](#input\_iam\_execution\_role\_name) | Friendly name of the lambda execution role. | `string` | n/a | yes |
| <a name="input_iam_execution_role_permissions_boundary_arn"></a> [iam\_execution\_role\_permissions\_boundary\_arn](#input\_iam\_execution\_role\_permissions\_boundary\_arn) | ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_lambda_loggroup_name"></a> [lambda\_loggroup\_name](#input\_lambda\_loggroup\_name) | Name of cloudwatch loggroup for lambda logging | `string` | `"*"` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | Alphanumeric suffix for all the resource names in this module. | `string` | `""` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_execution_role_arn"></a> [lambda\_execution\_role\_arn](#output\_lambda\_execution\_role\_arn) | Amazon Resource Name (ARN) specifying the lambda execution role. |
| <a name="output_lambda_execution_role_id"></a> [lambda\_execution\_role\_id](#output\_lambda\_execution\_role\_id) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_name"></a> [lambda\_execution\_role\_name](#output\_lambda\_execution\_role\_name) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_unique_id"></a> [lambda\_execution\_role\_unique\_id](#output\_lambda\_execution\_role\_unique\_id) | Stable and unique string identifying the lambda execution role. |
<!-- END_TF_DOCS -->