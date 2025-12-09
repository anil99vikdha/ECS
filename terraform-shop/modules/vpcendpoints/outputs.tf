# output "ecr_api_endpoint_dns" {
#   value       = aws_vpc_endpoint.ecr_api.dns_entries[*]
#   description = "ECR API endpoint DNS entries"
# }

# output "ecr_dkr_endpoint_dns" {
#   value       = aws_vpc_endpoint.ecr_dkr.dns_entries[*]
#   description = "ECR DKR endpoint DNS entries"
# }

# output "secretsmanager_endpoint_dns" {
#   value       = aws_vpc_endpoint.secretsmanager.dns_entries[*]
#   description = "Secrets Manager endpoint DNS entries"
# }

# output "logs_endpoint_dns" {
#   value       = aws_vpc_endpoint.logs.dns_entries[*]
#   description = "CloudWatch Logs endpoint DNS entries"
# }

# output "s3_endpoint_id" {
#   value       = aws_vpc_endpoint.s3.id
#   description = "S3 Gateway endpoint ID"
# }

# output "vpc_endpoint_dns_entries" {
#   value = {
#     ecr_api         = aws_vpc_endpoint.ecr_api.dns_entries[*]
#     ecr_dkr         = aws_vpc_endpoint.ecr_dkr.dns_entries[*]
#     secretsmanager  = aws_vpc_endpoint.secretsmanager.dns_entries[*]
#     logs            = aws_vpc_endpoint.logs.dns_entries[*]
#   }
#   description = "All VPC endpoint DNS entries"
# }
