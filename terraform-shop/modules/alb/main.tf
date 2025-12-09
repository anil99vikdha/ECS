# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  
  security_groups = [var.alb_sg_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, { Name = "${var.project_name}-alb" })
}

# Seller Target Group
resource "aws_lb_target_group" "seller" {
  name     = "${var.project_name}-seller-tg"
  port     = 5001
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/"  # App-specific health endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.project_name}-seller-tg" })
}

# Buyer Target Group
resource "aws_lb_target_group" "buyer" {
  name     = "${var.project_name}-buyer-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.project_name}-buyer-tg" })
}

# HTTP Listener (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.buyer.arn
  }
}

# Seller Route - only /seller (console screenshot)
resource "aws_lb_listener_rule" "seller" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  # Optional: transform /seller -> /
  # (you can't express regex transform in Terraform yet, so do it in app if needed.)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.seller.arn
  }

  condition {
    path_pattern {
      values = ["/seller"]
    }
  }
}