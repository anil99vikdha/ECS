variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
   Name = "trainxops-ecscluster"
  }
}
