
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
