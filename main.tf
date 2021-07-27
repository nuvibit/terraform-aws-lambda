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
  suffix   = title(var.resource_name_suffix)
  suffix_k = local.suffix == "" ? "" : format("-%s", local.suffix) // Kebap
  suffix_s = local.suffix == "" ? "" : format("_%s", local.suffix) // Snake

  lambda_name = format(
    "%s%s",
    lower(var.function_name),
    lower(local.suffix_k)
  )

  execution_role_name = format(
    "%s_execution_role%s",
    var.function_name,
    local.suffix_k,
  )

  log_policy_name = format(
    "%s_log_policy%s",
    var.function_name,
    local.suffix_k,
  )

  loggroup_name = format(
    "/aws/lambda/%s%s",
    lower(var.function_name),
    lower(local.suffix_k)
  )

  event_schedule_name = format(
    "%s-schedule%s",
    lower(var.function_name),
    lower(local.suffix_k)
  )

  kms_alias = format(
    "alias/%s_lambda_encryption_key%s",
    lower(var.function_name),
    lower(local.suffix_k)
  )

  kms_key_description = format(
    "Encryption key for Lambda Env Vars and Logs %s%s",
    lower(var.function_name),
    lower(local.suffix_k)
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "this" {
  function_name                  = local.lambda_name
  description                    = var.description
  filename                       = var.local_package_path
  package_type                   = var.package_type
  layers                         = var.layers
  handler                        = var.handler
  role                           = aws_iam_role.lambda.arn
  memory_size                    = var.memory_size
  runtime                        = var.runtime
  timeout                        = var.timeout
  source_code_hash               = filebase64sha256(var.local_package_path)
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  kms_key_arn                    = var.lambda_encryption == true ? aws_kms_alias.lambda_encryption[0].arn : null
  tags                           = var.resource_tags

  dynamic "vpc_config" {
    # add vpc_config when vpc_subnet_ids and vpc_security_group_ids are defined
    for_each = var.vpc_subnet_ids == null && var.vpc_security_group_ids == null ? [] : [true]
    iterator = filter
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dynamic "tracing_config" {
    # add tracing_config when tracing_mode is defined
    for_each = var.tracing_mode == null ? [] : [true]
    content {
      mode = var.tracing_mode
    }
  }

  dynamic "file_system_config" {
    # add file_system_config when file_system_config_arn and file_system_config_local_mount_path are defined
    for_each = var.file_system_config_arn == null && var.file_system_config_local_mount_path == null ? [] : [true]
    content {
      local_mount_path = var.file_system_config_local_mount_path
      arn              = var.file_system_config_arn
    }
  }

  dynamic "environment" {
    # add environment when environment_variables are defined
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy_attachment.lambda
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA TRIGGERS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "allowed_triggers" {
  for_each = {
    for k, v in var.trigger_permissions : k => v
  }

  # extract service_name from principal to append to statement_id e.g. s3.amazonaws.com = AllowExecutionFromS3
  statement_id  = format("AllowExecutionFrom%s", upper(split(".", each.value.principal)[0]))
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = each.value.principal
  # omit source_arn when 'any' to grant permission to any resource in principal
  source_arn = each.value.source_arn == "any" ? null : each.value.source_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM EXECUTE
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

resource "aws_iam_role" "lambda" {
  name                 = var.iam_execution_role_name == null ? local.execution_role_name : var.iam_execution_role_name
  assume_role_policy   = data.aws_iam_policy_document.lambda.json
  permissions_boundary = var.iam_execution_role_permissions_boundary_arn
  tags                 = var.resource_tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = length(var.iam_execution_policy_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = var.iam_execution_policy_arns[count.index]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH LOGS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = local.loggroup_name
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.lambda_encryption == true ? aws_kms_alias.lambda_encryption[0].arn : null
  tags              = var.resource_tags
}

resource "aws_iam_role_policy" "lambda_logs" {
  role   = aws_iam_role.lambda.name
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
        aws_cloudwatch_log_group.lambda_logs.name
      )
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH SCHEDULE RULE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "schedule" {
  count = var.schedule_expression != null ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}

resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.schedule_expression != null ? 1 : 0

  name                = local.event_schedule_name
  description         = "schedule event rule for lambda ${local.lambda_name}"
  schedule_expression = var.schedule_expression
  tags                = var.resource_tags
}

resource "aws_cloudwatch_event_target" "schedule" {
  count = var.schedule_expression != null ? 1 : 0

  target_id = "attach_schedule_to_lambda"
  rule      = aws_cloudwatch_event_rule.schedule[0].name
  arn       = aws_lambda_function.this.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH PATTERN RULES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "pattern" {
  for_each = toset(var.event_patterns)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pattern[each.key].arn
}

resource "aws_cloudwatch_event_rule" "pattern" {
  for_each = toset(var.event_patterns)

  name          = format("%s-pattern%s%s", var.function_name, index(var.event_patterns, each.value), local.suffix_k)
  description   = "pattern event rule for lambda ${local.lambda_name}"
  event_pattern = each.value
  tags          = var.resource_tags
}

resource "aws_cloudwatch_event_target" "pattern" {
  for_each = toset(var.event_patterns)

  target_id = "attach_schedule_to_lambda"
  rule      = aws_cloudwatch_event_rule.pattern[each.key].name
  arn       = aws_lambda_function.this.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ KMS ENCRYPTION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "lambda_encryption" {
  count               = var.lambda_encryption == true ? 1 : 0
  description         = local.kms_key_description
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.lambda_encryption.json
  tags                = var.resource_tags
}

resource "aws_kms_alias" "lambda_encryption" {
  count         = var.lambda_encryption == true ? 1 : 0
  name          = local.kms_alias
  target_key_id = aws_kms_key.lambda_encryption[0].key_id
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ KMS ENCRYPTION POLICY
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_encryption" {
  statement {
    sid     = "AllowLambdaService"
    actions = ["kms:*"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    resources = [
      aws_cloudwatch_log_group.lambda_logs.arn,
      aws_lambda_function.this.arn
    ]
  }

  statement {
    sid     = "AllowCloudwatchService"
    actions = ["kms:*"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
    resources = [
      aws_cloudwatch_log_group.lambda_logs.arn,
      aws_lambda_function.this.arn
    ]
  }
}
