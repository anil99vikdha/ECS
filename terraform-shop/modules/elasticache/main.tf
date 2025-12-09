# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for ElastiCache Valkey/Redis"

  tags = merge(var.tags, { Name = "${var.project_name}-cache-subnet-group" })
}

# ElastiCache Valkey Cluster (Redis-compatible)
resource "aws_elasticache_replication_group" "main" {
  description = "${var.project_name} Valkey cache cluster"
  replication_group_id       = "${var.project_name}-valkey"
  
  # Primary configuration
  num_cache_clusters         = var.num_cache_clusters
  node_type                  = var.node_type
  port                       = var.cache_port
  engine                     = var.engine
  engine_version             = var.engine_version
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  
  # Security - Use external SG
  security_group_ids         = [var.redis_sg_id]
  
  # Encryption
  at_rest_encryption_enabled = var.encryption_at_rest
  transit_encryption_enabled = var.encryption_in_transit
  
  # High availability
  automatic_failover_enabled = var.automatic_failover
  multi_az_enabled           = var.multi_az
  
  # Maintenance
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit

  tags = merge(var.tags, { Name = "${var.project_name}-valkey" })
}