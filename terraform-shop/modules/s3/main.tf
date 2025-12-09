# S3 Bucket
resource "aws_s3_bucket" "products" {
  bucket = "${var.project_name}-products-${data.aws_caller_identity.current.account_id}"
  tags   = merge(var.tags, { Name = "${var.project_name}-products" })
}

# Versioning
resource "aws_s3_bucket_versioning" "products" {
  bucket = aws_s3_bucket.products.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "products" {
  bucket = aws_s3_bucket.products.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "products" {
  bucket = aws_s3_bucket.products.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
