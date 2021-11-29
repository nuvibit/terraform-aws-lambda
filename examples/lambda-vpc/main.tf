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
  execution_role_name = format(
    "%s_execution_role%s",
    var.function_name,
    random_string.suffix.result
  )
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

  function_name                    = var.function_name
  description                      = var.description
  vpc_subnet_ids                   = [aws_subnet.first.id, aws_subnet.second.id]
  vpc_security_group_ids           = [aws_security_group.allow_https.id]
  local_package_path               = data.archive_file.lambda_package.output_path
  handler                          = "main.lambda_handler"
  create_execution_role            = false
  iam_execution_role_external_name = aws_iam_role.lambda.name
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
# ¦ LAMBDA EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name               = local.execution_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda.json
  tags               = var.resource_tags
}

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

resource "aws_iam_role_policy_attachment" "lambda_list_users" {
  role       = aws_iam_role.lambda.id
  policy_arn = data.aws_iam_policy.list_users.arn
}

data "aws_iam_policy_document" "list_users" {
  statement {
    sid       = "EnableOrganization"
    effect    = "Allow"
    actions   = ["iam:ListUsers"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_network" {
  role       = aws_iam_role.lambda.id
  policy_arn = data.aws_iam_policy.network.arn
}

data "aws_iam_policy" "network" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ VPC
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/23"
}

resource "aws_subnet" "first" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/24"
}

resource "aws_subnet" "second" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
