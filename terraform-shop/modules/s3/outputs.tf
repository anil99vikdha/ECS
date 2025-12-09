output "bucket_name" {
  value = aws_s3_bucket.products.id
}

output "bucket_arn" {
  value = aws_s3_bucket.products.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.products.bucket_regional_domain_name
}
