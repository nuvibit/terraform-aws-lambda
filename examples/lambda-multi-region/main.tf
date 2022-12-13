# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
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
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  execution_policy_name = format(
    "%s_execution_policy-%s",
    var.function_name,
    random_string.suffix.result,
  )
  event_patterns = [
    jsonencode(
      {
        "source" : ["aws.ec2"],
        "detail-type" : ["EC2 Instance State-change Notification"],
        "detail" : {
          "state" : ["terminated"]
        }
      }
    )
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ RANDOM SUFFIX
# ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 16
  number  = true
  lower   = true
  upper   = true
  special = false
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EXECUTION POLICIES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "list_users" {
  name   = local.execution_policy_name
  policy = data.aws_iam_policy_document.list_users.json
}

data "aws_iam_policy_document" "list_users" {
  # enable IAM in logging account
  statement {
    sid       = "EnableOrganization"
    effect    = "Allow"
    actions   = ["iam:ListUsers"]
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

  function_name       = var.function_name
  description         = var.description
  package_source_path = "${path.module}/lambda_files"
  handler             = "main.lambda_handler"
  trigger_sqs_enabled = true
  trigger_sqs_inbound_sns_topics = [
    {
      "sns_arn"            = aws_sns_topic.triggering_sns.arn
      "filter_policy_json" = "{\"autoRemediation\": [true]}"
    }
  ]
  iam_execution_role_path = "/lambda/"
  iam_execution_policy_arns = [
    aws_iam_policy.list_users.arn
  ]
  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  enable_encryption    = true
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.euc1
  }
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
  iam_execution_role_external_name = module.lambda_euc1.lambda_execution_role_name

  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  enable_encryption    = true
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.euw1
  }
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
  iam_execution_role_external_name = module.lambda_euc1.lambda_execution_role_name

  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.9"
  enable_encryption    = true
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
  tracing_mode         = "Active"
  providers = {
    aws = aws.use1
  }
}

