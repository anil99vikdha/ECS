variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "seller_task_arn" {
  description = "Seller task definition ARN"
  type        = string
}

variable "buyer_task_arn" {
  description = "Buyer task definition ARN"
  type        = string
}

variable "seller_desired_count" {
  description = "Number of seller service tasks"
  type        = number
  default     = 1
}

variable "buyer_desired_count" {
  description = "Number of buyer service tasks"
  type        = number
  default     = 1
}

variable "ecs_tasks_sg_id" {
  description = "ECS tasks security group ID"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "seller_target_group_arn" {
  description = "Seller ALB target group ARN"
  type        = string
}

variable "buyer_target_group_arn" {
  description = "Buyer ALB target group ARN"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
