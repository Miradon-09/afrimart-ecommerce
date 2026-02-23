# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of private subnets"
}

# Load Balancer Outputs
output "load_balancer_dns" {
  value       = module.loadbalancer.load_balancer_dns
  description = "DNS name of the load balancer"
}

output "load_balancer_id" {
  value       = module.loadbalancer.elb_id
  description = "ID of the Classic Load Balancer"
}

# Database Outputs
output "rds_endpoint" {
  value       = module.database.rds_endpoint
  description = "RDS database endpoint"
}

output "rds_database_name" {
  value       = module.database.rds_database_name
  description = "RDS database name"
}

# Redis Outputs
output "redis_endpoint" {
  value       = module.database.redis_endpoint
  description = "Redis cluster endpoint"
}

output "redis_port" {
  value       = module.database.redis_port
  description = "Redis cluster port"
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  value       = module.storage.bucket_name
  description = "S3 bucket name for uploads"
}

# Security Groups Outputs
output "alb_security_group_id" {
  value       = module.security.alb_sg_id
  description = "Security group ID for ALB"
}

output "web_security_group_id" {
  value       = module.security.web_sg_id
  description = "Security group ID for web servers"
}

output "db_security_group_id" {
  value       = module.security.db_sg_id
  description = "Security group ID for database"
}

output "cache_security_group_id" {
  value       = module.security.cache_sg_id
  description = "Security group ID for Redis cache"
}

# Application URL
output "application_url" {
  value       = "http://${module.loadbalancer.load_balancer_dns}"
  description = "URL to access the application"
}

# ECR Outputs
output "backend_repository_url" {
  value       = module.ecr.backend_repository_url
  description = "URL of the backend ECR repository"
}

output "frontend_repository_url" {
  value       = module.ecr.frontend_repository_url
  description = "URL of the frontend ECR repository"
}


output "jenkins_url" {
  value = module.compute.jenkins_url
}
