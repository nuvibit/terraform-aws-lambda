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

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
variable "function_name" {
  description = "Unique name for your Lambda Function."
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does."
  type        = string
  default     = ""
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  type        = list(string)
  default     = null

  validation {
    condition = var.layers == null ? true : alltrue([
      for arn in var.layers : can(regex("^arn:aws:lambda", arn))
    ]) && length(var.layers) < 6
    error_message = "Values must contain ARN of maximum 5 lambda-layers, starting with \"arn:aws:lambda\"."
  }
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = false
}

variable "package_type" {
  description = "Lambda deployment package type."
  type        = string
  default     = "Zip"

  validation {
    condition     = contains(["Zip"], var.package_type)
    error_message = "Value must be \"Zip\"."
  }
}

variable "local_package_path" {
  description = "Path to the function's deployment package within the local filesystem."
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint in your code."
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size < 10240 && floor(var.memory_size) == var.memory_size
    error_message = "Value must be between 128 MB and 10240 MB in 1-MB increments."
  }
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 3

  validation {
    condition     = var.timeout < 900 && floor(var.timeout) == var.timeout
    error_message = "Value must be less then 900 seconds."
  }
}

variable "runtime" {
  description = "Identifier of the function's runtime. See Runtimes for valid values."
  type        = string
  default     = null

  validation {
    condition = var.runtime == null ? true : contains([
      "nodejs", "nodejs4.3", "nodejs6.10",
      "nodejs8.10", "nodejs10.x", "nodejs12.x",
      "nodejs14.x", "java8", "java8.al2",
      "java11", "python2.7", "python3.6",
      "python3.7", "python3.8", "python3.9",
      "dotnetcore1.0", "dotnetcore2.0", "dotnetcore2.1",
      "dotnetcore3.1", "nodejs4.3-edge", "go1.x",
      "ruby2.5", "ruby2.7", "provided", "provided.al2"
    ], var.runtime)
    error_message = "Identifier of the function's runtime must be supported by AWS Lambda."
  }
}

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution."
  type        = map(string)
  default     = {}
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs associated with the Lambda function."
  type        = list(string)
  default     = []
}

variable "tracing_mode" {
  description = <<EOT
  Whether to to sample and trace a subset of incoming requests with AWS X-Ray. 
  Valid values are PassThrough and Active. 
  If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with "sampled=1". 
  If Active, Lambda will respect any tracing header it receives from an upstream service. 
  If no tracing header is received, Lambda will call X-Ray for a tracing decision.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.tracing_mode == null ? true : contains(["PassThrough", "Active"], var.tracing_mode)
    error_message = "Value must be \"PassThrough\" or \"Active\"."
  }
}

variable "file_system_config_arn" {
  description = "Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system."
  type        = string
  default     = null

  validation {
    condition     = var.file_system_config_arn == null ? true : can(regex("^arn:aws:elasticfilesystem", var.file_system_config_arn))
    error_message = "Value must contain ARN, starting with \"arn:aws:elasticfilesystem\"."
  }
}

variable "file_system_config_local_mount_path" {
  description = "Path where the function can access the file system, starting with /mnt/."
  type        = string
  default     = null

  validation {
    condition     = var.file_system_config_local_mount_path == null ? true : can(regex("^\\/mnt\\/", var.file_system_config_local_mount_path))
    error_message = "Value must start with \"/mnt/\"."
  }
}

variable "reserved_concurrent_executions" {
  description = <<EOT
  Amount of reserved concurrent executions for this lambda function. 
  A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations.
  EOT
  type        = number
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions >= -1
    error_message = "Value must be -1 or bigger."
  }
}

variable "trigger_permissions" {
  description = "Tuple of principals to grant lambda-trigger permission."
  type = list(object(
    {
      principal  = string # The principal who is getting trigger permission. e.g. s3.amazonaws.com, any valid AWS service principal or an AWS account ID.
      source_arn = string # The ARN of the specific resource within that service to grant permission to. Set to 'any' to grant permission to any resource in principal.
    }
  ))
  default = []

  validation {
    condition = var.trigger_permissions == [] ? true : alltrue([
      for p in var.trigger_permissions : can(regex(".amazonaws.com$|^\\d{12}$", p.principal)) && can(regex("^arn:aws:|^any$", p.source_arn))
    ])
    error_message = "Values must contain Principals, ending with \".amazonaws.com\" or matching exactly 12 digits and Source ARNs, starting with \"arn:aws\" or matching exactly \"any\"."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM
# ---------------------------------------------------------------------------------------------------------------------
variable "create_execution_role" {
  description = "Controls if IAM execution role should be created. If set to false an iam execute role ARN for 'iam_execution_role_external_arn' needs to be provided."
  type        = bool
  default     = true
}

variable "iam_execution_role_external_name" {
  description = "Name of an optional external IAM execution role outside this module. If create_execution_role is false, this value is required."
  type        = string
  default     = ""
}

variable "iam_execution_role_name" {
  description = "Friendly name of the lambda execution role. If omitted, will be generated with function name."
  type        = string
  default     = null
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

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH LOGS
# ---------------------------------------------------------------------------------------------------------------------
variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = null

  validation {
    condition     = var.log_retention_in_days == null ? true : contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "Value must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0."
  }
}

variable "log_kms_key_arn" {
  description = <<EOT
The ARN of the KMS Key to use when encrypting log data. 
Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. 
All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.log_kms_key_arn == null ? true : can(regex("^arn:aws:kms", var.log_kms_key_arn))
    error_message = "Value must contain ARN, starting with \"arn:aws:kms\"."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH SCHEDULE RULE
# ---------------------------------------------------------------------------------------------------------------------
variable "schedule_expression" {
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  type        = string
  default     = null
  validation {
    condition     = var.schedule_expression == null ? true : can(regex("^(rate\\(((1 (hour|minute|day))|(\\d+ (hours|minutes|days)))\\))|(cron\\(\\s*($|#|\\w+\\s*=|(\\?|\\*|(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?(?:,(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?)*)\\s+(\\?|\\*|(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?(?:,(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?)*)\\s+(\\?|\\*|(?:[01]?\\d|2[0-3])(?:(?:-|\\/|\\,)(?:[01]?\\d|2[0-3]))?(?:,(?:[01]?\\d|2[0-3])(?:(?:-|\\/|\\,)(?:[01]?\\d|2[0-3]))?)*)\\s+(\\?|\\*|(?:0?[1-9]|[12]\\d|3[01])(?:(?:-|\\/|\\,)(?:0?[1-9]|[12]\\d|3[01]))?(?:,(?:0?[1-9]|[12]\\d|3[01])(?:(?:-|\\/|\\,)(?:0?[1-9]|[12]\\d|3[01]))?)*)\\s+(\\?|\\*|(?:[1-9]|1[012])(?:(?:-|\\/|\\,)(?:[1-9]|1[012]))?(?:L|W)?(?:,(?:[1-9]|1[012])(?:(?:-|\\/|\\,)(?:[1-9]|1[012]))?(?:L|W)?)*|\\?|\\*|(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(?:(?:-)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))?(?:,(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(?:(?:-)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))?)*)\\s+(\\?|\\*|(?:[0-6])(?:(?:-|\\/|\\,|#)(?:[0-6]))?(?:L)?(?:,(?:[0-6])(?:(?:-|\\/|\\,|#)(?:[0-6]))?(?:L)?)*|\\?|\\*|(?:MON|TUE|WED|THU|FRI|SAT|SUN)(?:(?:-)(?:MON|TUE|WED|THU|FRI|SAT|SUN))?(?:,(?:MON|TUE|WED|THU|FRI|SAT|SUN)(?:(?:-)(?:MON|TUE|WED|THU|FRI|SAT|SUN))?)*)(|\\s)+(\\?|\\*|(?:|\\d{4})(?:(?:-|\\/|\\,)(?:|\\d{4}))?(?:,(?:|\\d{4})(?:(?:-|\\/|\\,)(?:|\\d{4}))?)*))\\))$", var.schedule_expression))
    error_message = "Value must match standard rate or cron expression."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CLOUDWATCH PATTERN RULES
# ---------------------------------------------------------------------------------------------------------------------
variable "event_patterns" {
  # https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html
  description = "A List of event patterns described as JSON objects."
  type        = list(string)
  default     = []

  validation {
    condition = var.event_patterns == [] ? true : alltrue([
      for pattern in var.event_patterns : (
        can(jsondecode(pattern)) ?
        can(jsondecode(pattern).source) :
        false
      )
    ])
    error_message = "Values must be valid JSON and have \"source\" field set."
  }
}
