output "redis_security_group_id" {
  value = aws_security_group.redis_security_group.id
}

output "parameter_group" {
  value = aws_elasticache_parameter_group.redis_parameter_group.id
}

output "redis_subnet_group_name" {
  value = aws_elasticache_subnet_group.redis_subnet_group.name
}

output "id" {
  value = aws_elasticache_replication_group.redis.id
}

output "port" {
  value = var.redis_port
}

output "endpoint" {
  value       = var.cluster_mode_enabled ? join("", compact(aws_elasticache_replication_group.redis[*].configuration_endpoint_address)) : join("", compact(aws_elasticache_replication_group.redis[*].primary_endpoint_address))
  description = "Redis primary or configuration endpoint, whichever is appropriate for the given cluster mode"
}
