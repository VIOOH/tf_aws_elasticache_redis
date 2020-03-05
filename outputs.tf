output "redis_security_group_id" {
  value = aws_security_group.redis_security_group.id
}

output "parameter_group" {
  value = "${var.redis_clusters == null ? aws_elasticache_parameter_group.redis_parameter_group_cluster[0].id : aws_elasticache_parameter_group.redis_parameter_group[0].id}"
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
  value = "${var.redis_clusters == null ? aws_elasticache_replication_group.redis.configuration_endpoint_address : aws_elasticache_replication_group.redis.primary_endpoint_address}"
}

