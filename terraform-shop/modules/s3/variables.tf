variable "project_name" {
  type        = string
  default     = "trainxops"
}

variable "tags" {
  type        = map(string)
  default     = {
   Name = "trainxops-s3"
  }
}
