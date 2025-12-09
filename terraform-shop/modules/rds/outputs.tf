output "db_instance_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "RDS instance endpoint"
}

output "db_instance_arn" {
  value       = aws_db_instance.main.arn
  description = "RDS instance ARN"
}

output "db_instance_username" {
  value       = aws_db_instance.main.username
  description = "RDS master username"
}

output "db_secret_arn" {
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
  description = "ARN of Secrets Manager secret for RDS password"
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.main.name
  description = "RDS subnet group name"
}

output "db_parameter_group_name" {
  value       = aws_db_parameter_group.main.name
  description = "RDS parameter group name"
}

output "db_secret_key_username" {
  description = "RDS username secret key ARN"
  value       = "${aws_db_instance.main.master_user_secret[0].secret_arn}:username::"
}

output "db_secret_key_password" {
  description = "RDS password secret key ARN"
  value       = "${aws_db_instance.main.master_user_secret[0].secret_arn}:password::"
}