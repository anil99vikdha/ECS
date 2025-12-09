variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "fargate_cpu" {
  description = "Fargate CPU units (256, 512, 1024, etc.)"
  type        = string
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate memory in MB (512, 1024, 2048, etc.)"
  type        = string
  default     = "512"
}

variable "seller_image" {
  description = "Docker image for seller service"
  type        = string
}

variable "buyer_image" {
  description = "Docker image for buyer service"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS database endpoint"
  type        = string
}

variable "valkey_endpoint" {
  description = "ElastiCache Valkey endpoint"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}

variable "flask_secret_key" {
  description = "falsk secret"
  type = string
}

variable "mysql_username" {
  description = "username"
  type        = string
}

variable "mysql_password" {
  description = "password"
  type        = string
}

variable "mysql_database" {
  description = "database name"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}


variable "dbinit_image" {
  description = "Docker image for db-init service"
  type        = string
}