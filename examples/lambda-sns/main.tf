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
# ¦ SNS TOPIC
resource "aws_sns_topic" "triggering_sns" {
  name = local.triggering_sns_sns_name
}

resource "aws_sns_topic_policy" "triggering_sns" {
  arn    = aws_sns_topic.triggering_sns.arn
  policy = data.aws_iam_policy_document.triggering_sns.json
}

data "aws_iam_policy_document" "triggering_sns" {
  statement {
    sid       = "AllowedPublishers"
    actions   = ["sns:Publish"]
    effect    = "Allow"
    resources = [aws_sns_topic.triggering_sns.arn]
  }
  statement {
    sid     = "AllowedSubscribers"
    actions = ["sns:Subscribe"]
    effect  = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.id)
      ]
    }
    resources = [aws_sns_topic.triggering_sns.arn]
  }
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
  trigger_sqs_enabled = true
  trigger_sqs_inbound_sns_topics = [
    {
      "sns_arn"            = aws_sns_topic.triggering_sns.arn
      "filter_policy_json" = "{\"autoRemediation\": [true]}"
    }
  ]
  schedule_expression     = "cron(0 12 * * ? *)"
  event_patterns          = local.event_patterns
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
