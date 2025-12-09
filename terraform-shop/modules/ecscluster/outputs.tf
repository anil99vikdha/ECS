output "cluster_id" {
  value       = aws_ecs_cluster.main.id
  description = "ECS Cluster ID"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.main.arn
  description = "ECS Cluster ARN"
}

output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS Cluster name"
}