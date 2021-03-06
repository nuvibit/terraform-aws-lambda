# Lambda Function

This example creates a Lambda Function with a `SNS ARN as input`.

## Which resources are deployed in this example?

* Lambda Function
* IAM Policy & Role
* Cloudwatch Log Group
* SQS triggering Lambda subscribed to SNS 

## How do you run this example?

1. Install [Terraform](https://www.terraform.io/).
1. Open `variables.tf`,  and fill in any required variables that don't have a
default.
1. Run `terraform init`.
1. Run `terraform plan`.
1. If the plan is successful, run `terraform apply`.
