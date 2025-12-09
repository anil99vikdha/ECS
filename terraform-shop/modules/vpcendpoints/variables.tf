variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Private route table IDs for S3 gateway endpoint"
  type        = list(string)
}

variable "vpc_endpoints_sg_id" {
  description = "VPC Endpoints security group ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_ssm_endpoints" {
  description = "Enable optional SSM and ECS endpoints"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
   Name = "trainxops-endpoints"
  }
}