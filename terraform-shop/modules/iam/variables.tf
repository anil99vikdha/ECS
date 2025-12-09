variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "s3_bucket" {
  description = "S3 bucket name for app access"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "create_service_role" {
  description = "Create ECS service role (optional)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
