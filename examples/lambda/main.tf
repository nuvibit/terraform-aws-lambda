# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
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
      version               = "%%PROVIDER_VERSION%%"
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
        "detail-type" : [
          "AWS Console Sign In via CloudTrail"
        ]
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
# ¦ LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
module "lambda" {
  # source  = "nuvibit/lambda/aws"
  # version = "~> 1.0"
  source = "../../"

  function_name       = var.function_name
  description         = var.description
  local_package_path  = data.archive_file.lambda_package.output_path
  handler             = "main.lambda_handler"
  schedule_expression = "cron(0 12 * * ? *)"
  event_patterns      = local.event_patterns
  iam_execution_policy_arns = [
    aws_iam_policy.list_users.arn
  ]
  environment_variables = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
  memory_size          = 128
  timeout              = 360
  runtime              = "python3.7"
  resource_tags        = var.resource_tags
  resource_name_suffix = random_string.suffix.result
}
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_files"
  output_path = "${path.module}/lambda_files_zipped/package.zip"
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
