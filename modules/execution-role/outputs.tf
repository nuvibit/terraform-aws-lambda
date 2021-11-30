output "lambda_execution_role_id" {
  description = "Name of the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].id : data.aws_iam_role.external_execution[0].id
}

output "lambda_execution_role_unique_id" {
  description = "Stable and unique string identifying the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].unique_id : data.aws_iam_role.external_execution[0].unique_id
}

output "lambda_execution_role_name" {
  description = "Name of the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.external_execution[0].name
}

output "lambda_execution_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the lambda execution role."
  value       = var.create_execution_role ? aws_iam_role.lambda[0].arn : data.aws_iam_role.external_execution[0].arn
}