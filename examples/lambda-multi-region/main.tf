# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  region = "eu-central-1"
  alias  = "euc1"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "euw1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "nuvibit"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-s-testing"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 3.15"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {
  provider = aws.euc1
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  execution_role_name = format(
    "%s_execution_role-%s",
    var.function_name,
    random_string.suffix.result,
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ RANDOM SUFFIX
# ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 16
  numeric = true
  lower   = true
  upper   = true
  special = false
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_execution_role" {
  name               = local.execution_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role_trust.json
  tags               = var.resource_tags
  provider           = aws.euc1
}

data "aws_iam_policy_document" "lambda_execution_role_trust" {
  statement {
    sid    = "TrustPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name     = replace(aws_iam_role.lambda_execution_role.name, "role", "policy")
  role     = aws_iam_role.lambda_execution_role.name
  policy   = data.aws_iam_policy_document.lambda_execution_policy.json
  provider = aws.euc1
}

#tfsec:ignore:AVD-AWS-0057
data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    sid    = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EUC1
# ---------------------------------------------------------------------------------------------------------------------
module "lambda_euc1" {
  # source  = "nuvibit/lambda/aws"
  # version = "~> 1.0"
  source = "../../"

  function_name                    = var.function_name
  description                      = var.description
  package_source_path              = "${path.module}/lambda_files"
  handler                          = "main.lambda_handler"
  create_execution_role            = false
  iam_execution_role_external_name = aws_iam_role.lambda_execution_role.name
  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.euc1
  }
  depends_on = [
    aws_iam_role.lambda_execution_role
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EUW1
# ---------------------------------------------------------------------------------------------------------------------
module "lambda_euw1" {
  # source  = "nuvibit/lambda/aws"
  # version = "~> 1.0"
  source = "../../"

  function_name                    = var.function_name
  description                      = var.description
  package_source_path              = "${path.module}/lambda_files"
  handler                          = "main.lambda_handler"
  create_execution_role            = false
  iam_execution_role_external_name = aws_iam_role.lambda_execution_role.name

  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.euw1
  }
  depends_on = [
    aws_iam_role.lambda_execution_role
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA USE1
# ---------------------------------------------------------------------------------------------------------------------
module "lambda_use1" {
  # source  = "nuvibit/lambda/aws"
  # version = "~> 1.0"
  source = "../../"

  function_name                    = var.function_name
  description                      = var.description
  package_source_path              = "${path.module}/lambda_files"
  handler                          = "main.lambda_handler"
  create_execution_role            = false
  iam_execution_role_external_name = aws_iam_role.lambda_execution_role.name

  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.use1
  }
  depends_on = [
    aws_iam_role.lambda_execution_role
  ]
}

