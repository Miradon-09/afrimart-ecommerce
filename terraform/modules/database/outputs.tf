output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS PostgreSQL endpoint"
}

output "rds_database_name" {
  value       = aws_db_instance.postgres.db_name
  description = "RDS database name"
}

output "rds_username" {
  value       = aws_db_instance.postgres.username
  description = "RDS master username"
  sensitive   = true
}

output "redis_endpoint" {
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
  description = "Redis cluster endpoint"
}

output "redis_port" {
  value       = aws_elasticache_cluster.redis.port
  description = "Redis cluster port"
}