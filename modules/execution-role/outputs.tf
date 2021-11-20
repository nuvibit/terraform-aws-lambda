output "lambda_execution_role_name" {
  description = "Name of the lambda execution role."
  value       = local.execution_role_name
}

output "lambda_execution_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].arn : var.iam_execution_role_external_arn
}

output "lambda_execution_role_unique_id" {
  description = "Stable and unique string identifying the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].unique_id : ""
}