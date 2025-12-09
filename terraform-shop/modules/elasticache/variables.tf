variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "trainxops"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "redis_sg_id" {
  description = "Security group ID for Redis/ElastiCache (from security_groups module)"
  type        = string
}

variable "engine" {
  description = "Cache engine (valkey or redis)"
  type        = string
  default     = "valkey"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0"
}

variable "node_type" {
  description = "Cache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (1 for single, 2 for replica)"
  type        = number
  default     = 1
}

variable "cache_port" {
  description = "Cache port"
  type        = number
  default     = 6379
}


variable "encryption_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "encryption_in_transit" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "Maintenance window (e.g., 'sun:23:00-sun:23:30')"
  type        = string
  default     = "sun:01:00-sun:02:00"
}

variable "snapshot_window" {
  description = "Snapshot window"
  type        = string
  default     = "00:00-01:00"
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention limit (days)"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
   Name = "trainxops-elasticache"
  }
}
