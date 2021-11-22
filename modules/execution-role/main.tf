# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  # This module is only being tested with Terraform 0.15.x and newer.
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
  execution_role_name_concat = format(
    "%s_execution_role%s",
    var.function_name,
    local.suffix_k,
  )

  execution_role_name = var.create_execution_role ? (var.iam_execution_role_name == null ? local.execution_role_name_concat : var.iam_execution_role_name) : replace(split(":", var.iam_execution_role_arn)[5], "role/", "")

  log_policy_name = format(
    "%s_log_policy%s",
    var.function_name,
    local.suffix_k,
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM LAMBDA EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  count = var.create_execution_role ? 1 : 0

  name                 = local.execution_role_name
  assume_role_policy   = data.aws_iam_policy_document.lambda.json
  permissions_boundary = var.iam_execution_role_permissions_boundary_arn
  tags                 = var.resource_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM LAMBDA EXECUTION ROLE - TRUST POLICY
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda" {
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

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM LAMBDA EXECUTION ROLE - POLICIES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda" {
  count = length(var.iam_execution_policy_arns)

  role       = local.execution_role_name
  policy_arn = var.iam_execution_policy_arns[count.index]
}

resource "aws_iam_role_policy" "lambda_logs" {
  role   = local.execution_role_name
  policy = data.aws_iam_policy_document.lambda_logs.json
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    sid    = "LogToCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      format(
        "arn:aws:logs:%s:%s:log-group:%s:*",
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        var.lambda_loggroup_name
      )
    ]
  }
}