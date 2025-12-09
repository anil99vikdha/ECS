# Seller ECS Service
resource "aws_ecs_service" "seller" {
  name            = "${var.project_name}-seller-service"
  cluster         = var.cluster_id
  task_definition = var.seller_task_arn
  desired_count   = var.seller_desired_count
  launch_type     = "FARGATE"

  # Health check grace period
  health_check_grace_period_seconds = 60

  network_configuration {
    security_groups  = var.ecs_tasks_sg_id
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.seller_target_group_arn
    container_name   = "seller"
    container_port   = 5001
  }

  # Auto rollback on failure
  deployment_controller {
    type = "ECS"
  }

  # Deployment circuit breaker
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = "${var.project_name}-seller-service" })
}

# Buyer ECS Service
resource "aws_ecs_service" "buyer" {
  name            = "${var.project_name}-buyer-service"
  cluster         = var.cluster_id
  task_definition = var.buyer_task_arn
  desired_count   = var.buyer_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    security_groups  = var.ecs_tasks_sg_id
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.buyer_target_group_arn
    container_name   = "buyer"
    container_port   = 5000
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = "${var.project_name}-buyer-service" })
}
