# Seller Task Definition
resource "aws_ecs_task_definition" "seller" {
  family                   = "${var.project_name}-seller"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "seller"
      image = var.seller_image
      essential = true

      portMappings = [
        {
          containerPort = 5001
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "S3_BUCKET", value = var.s3_bucket },
        { name = "MYSQL_HOST",  value = var.rds_endpoint },
        {name = "MYSQL_DATABASE",  value = var.mysql_database },
        { name = "AWS_REGION", value = var.aws_region },
        { name = "CLOUDFRONT_DOMAIN", value = var.cloudfront_domain_name },
        { name = "FLASK_SECRET_KEY", value = var.flask_secret_key }

      ],
            secrets = [
        { name = "MYSQL_USER",     valueFrom = var.mysql_username },   # :username::
        { name = "MYSQL_PASSWORD", valueFrom = var.mysql_password }    # :password::
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.seller.name
          awslogs-region        = var.aws_region
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.project_name}-seller-td" })
}

# Buyer Task Definition
resource "aws_ecs_task_definition" "buyer" {
  family                   = "${var.project_name}-buyer"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "buyer"
      image = var.buyer_image
      essential = true

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "FLASK_SECRET_KEY", value = var.flask_secret_key },
        { name = "MYSQL_HOST",  value = var.rds_endpoint },
        {name = "MYSQL_DATABASE",  value = var.mysql_database },
        { name = "REDIS_HOST", value = var.valkey_endpoint },
        { name = "REDIS_PORT", value = "6379" }
      ],
      secrets = [
        { name = "MYSQL_USER",     valueFrom = var.mysql_username },   # :username::
        { name = "MYSQL_PASSWORD", valueFrom = var.mysql_password }    # :password::
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.buyer.name
          awslogs-region        = var.aws_region
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.project_name}-buyer-td" })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "seller" {
  name              = "/ecs/${var.project_name}-seller"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.project_name}-seller-logs" })
}

resource "aws_cloudwatch_log_group" "buyer" {
  name              = "/ecs/${var.project_name}-buyer"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.project_name}-buyer-logs" })
}


# DB Init Task Definition
resource "aws_ecs_task_definition" "db_init" {
  family                   = "${var.project_name}-db-init"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "db-init"
      image = var.dbinit_image # Build & push your MySQL client image
      essential = true

      environment = [
        { name = "MYSQL_HOST",     value = var.rds_endpoint },
        { name = "MYSQL_DATABASE", value = var.mysql_database },
        { name = "AWS_REGION",     value = var.aws_region }
      ],
      secrets = [
        { name = "MYSQL_USER",     valueFrom = var.mysql_username },   # :username::
        { name = "MYSQL_PASSWORD", valueFrom = var.mysql_password }    # :password::
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.db_init.name
          awslogs-region        = var.aws_region
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.project_name}-db-init-td" })
}

# DB Init CloudWatch Log Group
resource "aws_cloudwatch_log_group" "db_init" {
  name              = "/ecs/${var.project_name}-db-init"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.project_name}-db-init-logs" })
}

