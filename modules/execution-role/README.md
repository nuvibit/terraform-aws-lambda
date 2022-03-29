
# AWS Terraform submodule to create a Lambda execution role

<!-- LOGO -->
<a href="https://nuvibit.com">
    <img src="https://nuvibit.com/images/logo/logo-nuvibit-dark.png" alt="nuvibit logo" title="nuvibit" align="right" width="200" />
</a>

<!-- SHIELDS -->
[![Maintained by nuvibit.com][nuvibit-shield]][nuvibit-url]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] submodule to deploy Lambda execution role on [AWS][aws-url

<!-- FEATURES -->
## Features
* Creates IAM Execution Role for Lambda and attaches internal and provided policies

<!-- USAGE -->
## Usage

### Lambda Function with local package
```hcl
module "execution_role" {
  source  = "nuvibit/lambda/aws//modules/execution-role"
  version = "~> 1.0"

  create_execution_role                       = "true"
  iam_execution_role_name                     = "lambda-execution-role"
  lambda_loggroup_name                        = aws_cloudwatch_log_group.lambda_logs.name

  resource_tags = {
    CostCenter = "project-1"
  }
}
```

<!-- EXAMPLES -->
## Examples

* [`examples/lambda-vpc`][lambda-vpc-test-url]

<!--- BEGIN_TF_DOCS --->
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
| [aws_iam_role_policy.sqs_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.external_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_execution_role_name"></a> [iam\_execution\_role\_name](#input\_iam\_execution\_role\_name) | Friendly name of the lambda execution role. | `string` | n/a | yes |
| <a name="input_create_execution_role"></a> [create\_execution\_role](#input\_create\_execution\_role) | Controls if IAM execution role resources should be created. | `bool` | `true` | no |
| <a name="input_iam_execution_policy_arns"></a> [iam\_execution\_policy\_arns](#input\_iam\_execution\_policy\_arns) | List of optional additional execution policy statement ARNs outside this module to attach to IAM Lambda execution role. | `list(string)` | `[]` | no |
| <a name="input_iam_execution_role_external_name"></a> [iam\_execution\_role\_external\_name](#input\_iam\_execution\_role\_external\_name) | Name of an optional external IAM execution role outside this module. If create\_execution\_role is false, this value is required. | `string` | `null` | no |
| <a name="input_iam_execution_role_path"></a> [iam\_execution\_role\_path](#input\_iam\_execution\_role\_path) | Path of the IAM role. | `string` | `null` | no |
| <a name="input_iam_execution_role_permissions_boundary_arn"></a> [iam\_execution\_role\_permissions\_boundary\_arn](#input\_iam\_execution\_role\_permissions\_boundary\_arn) | ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_lambda_loggroup_name"></a> [lambda\_loggroup\_name](#input\_lambda\_loggroup\_name) | Name of cloudwatch loggroup for lambda logging | `string` | `"*"` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | Alphanumeric suffix for all the resource names in this module. | `string` | `""` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |
| <a name="input_trigger_sqs_arn"></a> [trigger\_sqs\_arn](#input\_trigger\_sqs\_arn) | ARN of the SQS triggering the Lambda. | `string` | `""` | no |
| <a name="input_trigger_sqs_enabled"></a> [trigger\_sqs\_enabled](#input\_trigger\_sqs\_enabled) | Specifies, if a SQS for triggering the Lambda was created. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_execution_role_arn"></a> [lambda\_execution\_role\_arn](#output\_lambda\_execution\_role\_arn) | Amazon Resource Name (ARN) specifying the lambda execution role. |
| <a name="output_lambda_execution_role_id"></a> [lambda\_execution\_role\_id](#output\_lambda\_execution\_role\_id) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_name"></a> [lambda\_execution\_role\_name](#output\_lambda\_execution\_role\_name) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_unique_id"></a> [lambda\_execution\_role\_unique\_id](#output\_lambda\_execution\_role\_unique\_id) | Stable and unique string identifying the lambda execution role. |

<!--- END_TF_DOCS --->

<!-- AUTHORS -->
## Authors

This module is maintained by [Nuvibit][nuvibit-url] with help from [these amazing contributors][contributors-url]

<!-- LICENSE -->
## License

This module is licensed under Apache 2.0
<br />
See [LICENSE][license-url] for full details

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2021 Nuvibit AG</p>

<!-- MARKDOWN LINKS & IMAGES -->
[nuvibit-shield]: https://img.shields.io/badge/maintained%20by-nuvibit.com-%235849a6.svg?style=flat&color=1c83ba
[nuvibit-url]: https://nuvibit.com
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D0.15.0-blue.svg?style=flat&color=blueviolet
[terraform-version-url]: https://www.terraform.io/upgrade-guides/0-15.html
[release-shield]: https://img.shields.io/github/v/release/nuvibit/terraform-aws-lambda?style=flat&color=success
[architecture-png]: https://github.com/nuvibit/terraform-aws-lambda/blob/main/docs/architecture.png?raw=true
[release-url]: https://github.com/nuvibit/terraform-aws-lambda/releases
[contributors-url]: https://github.com/nuvibit/terraform-aws-lambda/graphs/contributors
[license-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/main/LICENSE
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
[lambda-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/main/examples/lambda
[lambda-vpc-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/main/examples/lambda-vpc
