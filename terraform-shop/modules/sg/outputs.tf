output "ecs_tasks_sg_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "Security group ID for ECS tasks"
}

output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID for ALB"
}

output "rds_sg_id" {
  value       = aws_security_group.rds.id
  description = "Security group ID for RDS"
}

output "redis_sg_id" {
  value       = aws_security_group.redis.id
  description = "Security group ID for Redis/ElastiCache"
}

output "security_group_ids" {
  value = {
    ecs_tasks = aws_security_group.ecs_tasks.id
    alb       = aws_security_group.alb.id
    rds       = aws_security_group.rds.id
    redis     = aws_security_group.redis.id
  }
  description = "All security group IDs"
}

output "vpc_endpoints_sg_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "Security group ID for VPC Endpoints"
}