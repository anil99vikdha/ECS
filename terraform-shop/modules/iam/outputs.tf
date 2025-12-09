output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution.arn
  description = "ARN of ECS task execution role"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.ecs_task.arn
  description = "ARN of ECS task role (app permissions)"
}

output "ecs_service_role_arn" {
  value       = var.create_service_role ? aws_iam_role.ecs_service[0].arn : null
  description = "ARN of ECS service role (if created)"
}

output "ecs_task_role_name" {
  value       = aws_iam_role.ecs_task.name
  description = "Name of ECS task role"
}

output "ecs_task_execution_role_name" {
  value       = aws_iam_role.ecs_task_execution.name
  description = "Name of ECS task execution role"
}

output "iam_role_arns" {
  value = {
    task_execution = aws_iam_role.ecs_task_execution.arn
    task           = aws_iam_role.ecs_task.arn
    service        = var.create_service_role ? aws_iam_role.ecs_service[0].arn : null
  }
  description = "All IAM role ARNs"
}
