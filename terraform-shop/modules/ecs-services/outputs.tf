output "seller_service_arn" {
  value       = aws_ecs_service.seller.arn
  description = "Seller ECS service ARN"
}

output "seller_service_name" {
  value       = aws_ecs_service.seller.name
  description = "Seller ECS service name"
}

output "buyer_service_arn" {
  value       = aws_ecs_service.buyer.arn
  description = "Buyer ECS service ARN"
}

output "buyer_service_name" {
  value       = aws_ecs_service.buyer.name
  description = "Buyer ECS service name"
}

output "service_arns" {
  value = {
    seller = aws_ecs_service.seller.arn
    buyer  = aws_ecs_service.buyer.arn
  }
  description = "All ECS service ARNs"
}

output "service_names" {
  value = {
    seller = aws_ecs_service.seller.name
    buyer  = aws_ecs_service.buyer.name
  }
  description = "All ECS service names"
}
