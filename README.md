
# AWS Lambda Terraform module

<!-- LOGO -->
<a href="https://nuvibit.com">
    <img src="https://nuvibit.com/img/logo.png" alt="nuvibit logo" title="nuvibit" align="right" width="100" />
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
  runtime            = "python3.8"
  local_package_path = "../my_lambda.zip"
  tags = {
    Name = "my_lambda"
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
  runtime                = "python3.8"
  local_package_path     = "../my_lambda.zip"
  vpc_subnet_ids         = ["subnet-b46032ec", "subnet-a46032fc"]
  vpc_security_group_ids = ["sg-51530134"]

  tags = {
    Name = "my_lambda_vpc"
  }
}
```

<!-- EXAMPLES -->
## Examples

* [`examples/lambda`][lambda-test-url]
* [`examples/lambda-vpc`][lambda-vpc-test-url]

<!--- BEGIN_TF_DOCS --->
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
[architecture-png]: https://github.com/nuvibit/terraform-aws-lambda/blob/master/docs/architecture.png?raw=true
[release-url]: https://github.com/nuvibit/terraform-aws-lambda/releases
[contributors-url]: https://github.com/nuvibit/terraform-aws-lambda/graphs/contributors
[license-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/master/LICENSE
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
[nuvibit-product-url]: https://nuvibit.com/products
[lambda-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/master/examples/lambda
[lambda-vpc-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/master/examples/lambda-vpc
[example-sub-module-test-url]: https://github.com/nuvibit/terraform-aws-lambda/tree/master/examples/example-resource-module
