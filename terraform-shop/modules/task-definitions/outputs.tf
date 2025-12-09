output "seller_task_arn" {
  value       = aws_ecs_task_definition.seller.arn
  description = "Seller task definition ARN"
}

output "buyer_task_arn" {
  value       = aws_ecs_task_definition.buyer.arn
  description = "Buyer task definition ARN"
}

output "dbinit_task_arn" {
  value = aws_ecs_task_definition.db_init.arn
  description = "DB Init task definition ARN"
}

output "seller_task_family" {
  value       = aws_ecs_task_definition.seller.family
  description = "Seller task family name"
}

output "buyer_task_family" {
  value       = aws_ecs_task_definition.buyer.family
  description = "Buyer task family name"
}

output "seller_log_group" {
  value       = aws_cloudwatch_log_group.seller.name
  description = "Seller log group name"
}

output "buyer_log_group" {
  value       = aws_cloudwatch_log_group.buyer.name
  description = "Buyer log group name"
}
