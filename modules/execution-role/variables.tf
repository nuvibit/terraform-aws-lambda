variable "create_execution_role" {
  description = "Controls if IAM execution role resources should be created."
  type        = bool
  default     = true
}

variable "iam_execution_role_external_arn" {
  description = "ARN of an optional external IAM execution role outside this module. If omitted, an execution role will be created."
  type        = string
  default     = null
}

variable "iam_execution_role_name" {
  description = "Friendly name of the lambda execution role."
  type        = string
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

variable "lambda_loggroup_name" {
  description = "Name of cloudwatch loggroup for lambda logging"
  type        = string
  default     = "*"
}