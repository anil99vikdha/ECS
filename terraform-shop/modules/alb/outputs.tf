  output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name - Access: http://this/seller or /buyer"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "ALB canonical hosted zone ID (Route53)"
}

output "seller_target_group_arn" {
  value       = aws_lb_target_group.seller.arn
  description = "Seller target group ARN (ECS service)"
}

output "seller_target_group_id" {
  value       = aws_lb_target_group.seller.id
  description = "Seller target group ID"
}

output "buyer_target_group_arn" {
  value       = aws_lb_target_group.buyer.arn
  description = "Buyer target group ARN (ECS service)"
}

output "buyer_target_group_id" {
  value       = aws_lb_target_group.buyer.id
  description = "Buyer target group ID"
}

output "http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "HTTP listener ARN"
}

output "seller_listener_rule_arn" {
  value       = aws_lb_listener_rule.seller.arn
  description = "Seller listener rule ARN"
}

output "alb_access_urls" {
  value = {
    seller = "http://${aws_lb.main.dns_name}/seller"
    buyer  = "http://${aws_lb.main.dns_name}/buyer"
    root   = "http://${aws_lb.main.dns_name}/"
  }
  description = "Ready-to-use ALB URLs"
}

output "alb_resources" {
  value = {
    arn                = aws_lb.main.arn
    dns_name           = aws_lb.main.dns_name
    zone_id            = aws_lb.main.zone_id
    seller_tg_arn      = aws_lb_target_group.seller.arn
    buyer_tg_arn       = aws_lb_target_group.buyer.arn
    http_listener_arn  = aws_lb_listener.http.arn
  }
  description = "All ALB resources summary"
}
