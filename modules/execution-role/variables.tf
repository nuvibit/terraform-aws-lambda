variable "function_name" {
  description = "Unique name for your Lambda Function."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------
variable "create_execution_role" {
  description = "Controls if IAM execution role resources should be created."
  type        = bool
  default     = true
}

variable "iam_execution_role_external_name" {
  description = "Name of an optional external IAM execution role outside this module. If create_execution_role is false, this value is required."
  type        = string
  default     = null
}

variable "iam_execution_role_name" {
  description = "Friendly name of the lambda execution role."
  type        = string
}

variable "iam_execution_role_path" {
  description = "Path of the IAM role."
  type        = string
  default     = null

  validation {
    condition     = var.iam_execution_role_path == null ? true : can(regex("^(\\/|\\/.*\\/)$", var.iam_execution_role_path))
    error_message = "Value must be \"/\" or start and end with \"/\"."
  }
}

variable "iam_execution_role_permissions_boundary_arn" {
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null

  validation {
    condition     = var.iam_execution_role_permissions_boundary_arn == null ? true : can(regex("^arn:aws:iam", var.iam_execution_role_permissions_boundary_arn))
    error_message = "Value must contain ARN, starting with 'arn:aws:iam'."
  }
}

variable "iam_execution_policy_arns" {
  description = "List of optional additional execution policy statement ARNs outside this module to attach to IAM Lambda execution role."
  type        = list(string)
  default     = []

  validation {
    condition = var.iam_execution_policy_arns == [] ? true : alltrue([
      for arn in var.iam_execution_policy_arns : can(regex("^arn:aws:iam", arn))
    ])
    error_message = "Values must contain ARN, starting with \"arn:aws:iam\"."
  }
}

variable "trigger_sqs_enabled" {
  description = "Specifies, if a SQS for triggering the Lambda was created."
  type        = bool
  default     = false
}

variable "trigger_sqs_arn" {
  description = "ARN of the SQS triggering the Lambda."
  type        = string
  default     = ""
  validation {
    condition     = var.trigger_sqs_arn == "" ? true : can(regex("^arn:aws:sqs:", var.trigger_sqs_arn))
    error_message = "Value must contain ARN, starting with \"arn:aws:sqs:\"."
  }
}

variable "lambda_loggroup_name" {
  description = "Name of cloudwatch loggroup for lambda logging"
  type        = string
  default     = "*"
}

variable "enable_tracing" {
  description = "If true permissons for aws x ray will be added"
  default     = true
  type        = bool
}

variable "enable_encryption" {
  description = "If true permissons for kms policies will be attached to the execution role. Requires kms_key_arn."
  default     = true
  type        = bool
}

variable "kms_key_arn" {
  description = "ARN of the kms key used to encrypt logs and sqs messages"
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null ? true : can(regex("^arn:aws:kms", var.kms_key_arn))
    error_message = "Value must contain ARN, starting with \"arn:aws:kms\"."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}

variable "resource_name_suffix" {
  description = "Alphanumeric suffix for all the resource names in this module."
  type        = string
  default     = ""

  validation {
    condition     = var.resource_name_suffix == "" ? true : can(regex("[[:alnum:]]", var.resource_name_suffix))
    error_message = "Value must be alphanumeric."
  }
}
