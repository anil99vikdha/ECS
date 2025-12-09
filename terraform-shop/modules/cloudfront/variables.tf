variable "project_name" {
  type    = string
  default = "trainxops"
}

variable "s3_bucket_name" {
  description = "S3 bucket name (from S3 module)"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN (from S3 module)"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  type        = string
}

variable "tags" {
  type = map(string)
  default     = {
   Name = "trainxops-cloudfront"
  }
}
