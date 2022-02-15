
# AWS Lambda Terraform module

<!-- LOGO -->
<a href="https://nuvibit.com">
    <img src="https://nuvibit.com/images/logo/logo-nuvibit-dark.png" alt="nuvibit logo" title="nuvibit" align="right" width="200" />
</a>

<!-- SHIELDS -->
[![Maintained by nuvibit.com][nuvibit-shield]][nuvibit-url]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] module to deploy Lambda resources on [AWS][aws-url]

<!-- ARCHITECTURE -->
## Architecture
![lambda architecture][architecture-png]

<!-- FEATURES -->
## Features
* Creates a Lambda Function
* Creates IAM Execution Role for Lambda and attaches internal and provided policies
* Optionally provide external IAM Execution Role ARN and skip creating new Execution Role
* Creates a CloudWatch Log Group for Lambda logs
* Optionally creates a CloudWatch Event Rule (for scheduling)

<!-- USAGE -->
## Usage

### Lambda Function with local package
```hcl
module "lambda" {
  source  = "nuvibit/lambda/aws"
  version = "~> 1.0"

  function_name      = "my_lambda"
  description        = "my lambda function"
  handler            = "main.lambda_handler"
  runtime            = "python3.9"
  local_package_path = "../my_lambda.zip"

  resource_tags = {
    CostCenter = "project-1"
  }
}
```

### Lambda Function in VPC
```hcl
module "lambda_vpc" {
  source  = "nuvibit/lambda/aws"
  version = "~> 1.0"

  function_name          = "my_lambda_vpc"
  description            = "my lambda function in vpc"
  handler                = "main.lambda_handler"
  runtime                = "python3.9"
  local_package_path     = "../my_lambda.zip"
  vpc_subnet_ids         = ["subnet-b46032ec", "subnet-a46032fc"]
  vpc_security_group_ids = ["sg-51530134"]

  resource_tags = {
    CostCenter = "project-1"
  }
}
```

### Lambda Function with external IAM execute policy
```hcl
data "aws_iam_role" "lambda" {
  name = "my_lambda_execute_role"
}

module "lambda_vpc" {
  source  = "nuvibit/lambda/aws"
  version = "~> 1.0"

  create_execution_role            = false
  iam_execution_role_external_name = data.aws_iam_role.lambda.name
  function_name                    = "my_lambda_vpc"
  description                      = "my lambda function in vpc"
  handler                          = "main.lambda_handler"
  runtime                          = "python3.9"
  local_package_path               = "../my_lambda.zip"

  resource_tags = {
    CostCenter = "project-1"
  }
}
```

<!-- EXAMPLES -->
## Examples

* [`examples/lambda`][lambda-test-url]
* [`examples/lambda-vpc`][lambda-vpc-test-url]
* [`examples/lambda-sns`][lambda-sns-test-url]

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_execution_role"></a> [execution\_role](#module\_execution\_role) | ./modules/execution-role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.pattern](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.pattern](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_event_source_mapping.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allowed_triggers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.pattern](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic_subscription.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function. | `string` | n/a | yes |
| <a name="input_create_execution_role"></a> [create\_execution\_role](#input\_create\_execution\_role) | Controls if IAM execution role should be created. If set to false an iam execute role ARN for 'iam\_execution\_role\_external\_arn' needs to be provided. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does. | `string` | `""` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables that are accessible from the function code during execution. | `map(string)` | `{}` | no |
| <a name="input_event_patterns"></a> [event\_patterns](#input\_event\_patterns) | A List of event patterns described as JSON objects. | `list(string)` | `[]` | no |
| <a name="input_file_system_config_arn"></a> [file\_system\_config\_arn](#input\_file\_system\_config\_arn) | Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system. | `string` | `null` | no |
| <a name="input_file_system_config_local_mount_path"></a> [file\_system\_config\_local\_mount\_path](#input\_file\_system\_config\_local\_mount\_path) | Path where the function can access the file system, starting with /mnt/. | `string` | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code. | `string` | `""` | no |
| <a name="input_iam_execution_policy_arns"></a> [iam\_execution\_policy\_arns](#input\_iam\_execution\_policy\_arns) | List of optional additional execution policy statement ARNs outside this module to attach to IAM Lambda execution role. | `list(string)` | `[]` | no |
| <a name="input_iam_execution_role_external_name"></a> [iam\_execution\_role\_external\_name](#input\_iam\_execution\_role\_external\_name) | Name of an optional external IAM execution role outside this module. If create\_execution\_role is false, this value is required. | `string` | `""` | no |
| <a name="input_iam_execution_role_name"></a> [iam\_execution\_role\_name](#input\_iam\_execution\_role\_name) | Friendly name of the lambda execution role. If omitted, will be generated with function name. | `string` | `null` | no |
| <a name="input_iam_execution_role_path"></a> [iam\_execution\_role\_path](#input\_iam\_execution\_role\_path) | Path of the IAM role. | `string` | `null` | no |
| <a name="input_iam_execution_role_permissions_boundary_arn"></a> [iam\_execution\_role\_permissions\_boundary\_arn](#input\_iam\_execution\_role\_permissions\_boundary\_arn) | ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. | `list(string)` | `null` | no |
| <a name="input_local_package_path"></a> [local\_package\_path](#input\_local\_package\_path) | Path to the function's deployment package within the local filesystem. | `string` | `null` | no |
| <a name="input_log_kms_key_arn"></a> [log\_kms\_key\_arn](#input\_log\_kms\_key\_arn) | The ARN of the KMS Key to use when encrypting log data. <br>Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. <br>All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested. | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. | `number` | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime. | `number` | `128` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | Lambda deployment package type. | `string` | `"Zip"` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | Whether to publish creation/change as new Lambda Function Version. | `bool` | `false` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function. <br>  A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. | `number` | `-1` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | Alphanumeric suffix for all the resource names in this module. | `string` | `""` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime. See Runtimes for valid values. | `string` | `null` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Amount of time your Lambda Function has to run in seconds. | `number` | `3` | no |
| <a name="input_tracing_mode"></a> [tracing\_mode](#input\_tracing\_mode) | Whether to to sample and trace a subset of incoming requests with AWS X-Ray. <br>  Valid values are PassThrough and Active. <br>  If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with "sampled=1". <br>  If Active, Lambda will respect any tracing header it receives from an upstream service. <br>  If no tracing header is received, Lambda will call X-Ray for a tracing decision. | `string` | `null` | no |
| <a name="input_trigger_permissions"></a> [trigger\_permissions](#input\_trigger\_permissions) | Tuple of principals to grant lambda-trigger permission. | <pre>list(object(<br>    {<br>      principal  = string # The principal who is getting trigger permission. e.g. s3.amazonaws.com, any valid AWS service principal or an AWS account ID.<br>      source_arn = string # The ARN of the specific resource within that service to grant permission to. Set to 'any' to grant permission to any resource in principal.<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_trigger_sqs_access_policy_source_json"></a> [trigger\_sqs\_access\_policy\_source\_json](#input\_trigger\_sqs\_access\_policy\_source\_json) | In case you have custom sources feeding the optional Trigger-SQS, you have to provide the snip of the SQS Access Policy here. | `string` | `null` | no |
| <a name="input_trigger_sqs_enabled"></a> [trigger\_sqs\_enabled](#input\_trigger\_sqs\_enabled) | Specifies if an SQS for triggering the Lambda will be created. | `bool` | `false` | no |
| <a name="input_trigger_sqs_inbound_sns_topics"></a> [trigger\_sqs\_inbound\_sns\_topics](#input\_trigger\_sqs\_inbound\_sns\_topics) | Only provide, if var.trigger\_sqs\_enabled = true. List of SNS ARNs the Trigger-SQS will be subscribed to. | <pre>list(object(<br>    {<br>      sns_arn            = string # The ARN of the SNS topic that will trigger the Lambda via the created SQS.<br>      filter_policy_json = string # Policy for filtering the stream to the SQS subscription to specific SNS items.<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs associated with the Lambda function. | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet IDs associated with the Lambda function. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function. |
| <a name="output_lambda_cloudwatch_log_group_arn"></a> [lambda\_cloudwatch\_log\_group\_arn](#output\_lambda\_cloudwatch\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the lambda log group. |
| <a name="output_lambda_execution_role_arn"></a> [lambda\_execution\_role\_arn](#output\_lambda\_execution\_role\_arn) | Amazon Resource Name (ARN) specifying the lambda execution role. |
| <a name="output_lambda_execution_role_id"></a> [lambda\_execution\_role\_id](#output\_lambda\_execution\_role\_id) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_name"></a> [lambda\_execution\_role\_name](#output\_lambda\_execution\_role\_name) | Name of the lambda execution role. |
| <a name="output_lambda_execution_role_unique_id"></a> [lambda\_execution\_role\_unique\_id](#output\_lambda\_execution\_role\_unique\_id) | Stable and unique string identifying the lambda execution role. |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | Unique name identifying your Lambda Function. |
| <a name="output_lambda_pattern_cloudwatch_event_rule_arns"></a> [lambda\_pattern\_cloudwatch\_event\_rule\_arns](#output\_lambda\_pattern\_cloudwatch\_event\_rule\_arns) | The Amazon Resource Name (ARN) of the lambda pattern rule. |
| <a name="output_lambda_pattern_cloudwatch_event_rule_ids"></a> [lambda\_pattern\_cloudwatch\_event\_rule\_ids](#output\_lambda\_pattern\_cloudwatch\_event\_rule\_ids) | The name of the lambda pattern rule. |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | ARN identifying your Lambda Function Version (if versioning is enabled via publish = true). |
| <a name="output_lambda_schedule_cloudwatch_event_rule_arn"></a> [lambda\_schedule\_cloudwatch\_event\_rule\_arn](#output\_lambda\_schedule\_cloudwatch\_event\_rule\_arn) | The Amazon Resource Name (ARN) of the lambda scheduling rule. |
| <a name="output_lambda_schedule_cloudwatch_event_rule_id"></a> [lambda\_schedule\_cloudwatch\_event\_rule\_id](#output\_lambda\_schedule\_cloudwatch\_event\_rule\_id) | The name of the lambda scheduling rule. |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of your Lambda Function. |
| <a name="output_sqs_trigger_arn"></a> [sqs\_trigger\_arn](#output\_sqs\_trigger\_arn) | Specifies if a SQS trigger for the Lambda should be created. |

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
[lambda-sns-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/main/examples/lambda-sns
