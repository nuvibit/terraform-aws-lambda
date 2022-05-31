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
data "aws_iam_role" "external_execution" {
  count = var.create_execution_role ? 0 : 1
  name  = var.iam_execution_role_external_name
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM LAMBDA EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  count = var.create_execution_role ? 1 : 0

  name                 = var.iam_execution_role_name
  path                 = var.iam_execution_role_path
  assume_role_policy   = data.aws_iam_policy_document.lambda.json
  permissions_boundary = var.iam_execution_role_permissions_boundary_arn
  tags                 = var.resource_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM LAMBDA EXECUTION POLICY
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
# ¦ ATTACH IAM POLICIES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda" {
  count = var.create_execution_role ? length(var.iam_execution_policy_arns) : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = var.iam_execution_policy_arns[count.index]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA LOGGING - IAM POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_logs" {
  name   = "AllowLambdaDebugLogs"
  role   = var.create_execution_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.external_execution[0].name
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

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SQS - IAM POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "sqs_trigger" {
  count = var.trigger_sqs_enabled == true ? 1 : 0

  name   = "AllowTriggerSqs"
  role   = var.create_execution_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.external_execution[0].name
  policy = data.aws_iam_policy_document.sqs_trigger[0].json
}

data "aws_iam_policy_document" "sqs_trigger" {
  count = var.trigger_sqs_enabled == true ? 1 : 0

  statement {
    sid    = "SqsTrigger"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      var.trigger_sqs_arn
    ]
  }
}

resource "aws_iam_role_policy" "sqs_kms" {
  count = var.enable_encryption ? 1 : 0

  name   = "AllowKmsCmkAccess"
  role   = var.create_execution_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.external_execution[0].name
  policy = data.aws_iam_policy_document.sqs_kms[0].json
}

data "aws_iam_policy_document" "sqs_kms" {
  count = var.enable_encryption ? 1 : 0

  statement {
    sid    = "SqsTrigger"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      var.trigger_sqs_arn
    ]
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ X-RAY - IAM POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "aws_xray_write_only_access" {
  count      = var.enable_tracing == true ? 1 : 0
  role       = var.create_execution_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.external_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
