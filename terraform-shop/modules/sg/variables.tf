variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {
   Name = "trainxops-sg"
  }
}
