# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix       = "${var.project_name}-db-subnet-"
  subnet_ids        = var.private_subnet_ids
  description       = "Subnet group for RDS MySQL"

  tags = merge(var.tags, { Name = "${var.project_name}-db-subnet-group" })
}

# RDS MySQL Instance - Fixed master_user_secret error
resource "aws_db_instance" "main" {
  identifier                      = "${var.project_name}-mysql"
  engine                          = "mysql"
  engine_version                  = var.mysql_version
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  storage_type                    = var.storage_type
  storage_encrypted               = true
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  backup_retention_period         = var.backup_retention_period
  multi_az                        = var.multi_az
  publicly_accessible             = false

  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [var.rds_sg_id]

  # Fixed: Use manage_master_user_password without master_user_secret block
  username                        = var.db_username
  manage_master_user_password     = true  # Auto-creates Secrets Manager secret

  parameter_group_name            = aws_db_parameter_group.main.name
  db_name                         = var.db_name

  performance_insights_enabled    = var.performance_insights_enabled
  monitoring_interval             = var.monitoring_interval
  # monitoring_role_arn          = var.monitoring_role_arn  # Optional

  tags = merge(var.tags, { Name = "${var.project_name}-mysql" })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  name_prefix       = "${var.project_name}-mysql-"
  family            = "mysql8.0"
  description       = "Custom parameter group for TrainXOps MySQL"

  parameter {
    name  = "general_log"
    value = "0"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-mysql-params" })
}