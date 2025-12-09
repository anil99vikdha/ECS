output "primary_endpoint_address" {
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
  description = "Primary endpoint address (use this in app)"
}

output "primary_endpoint_port" {
  value       = aws_elasticache_replication_group.main.port
  description = "Primary endpoint port"
}

output "replication_group_id" {
  value       = aws_elasticache_replication_group.main.id
  description = "Replication group ID"
}

output "replication_group_arn" {
  value       = aws_elasticache_replication_group.main.arn
  description = "Replication group ARN"
}

output "subnet_group_name" {
  value       = aws_elasticache_subnet_group.main.name
  description = "ElastiCache subnet group name"
}
