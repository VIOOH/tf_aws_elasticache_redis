data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "random_id" "salt" {
  byte_length = 8
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = replace(format("%.20s", "${var.name}-${var.env}"), "/-$/", "")
  replication_group_description = "Terraform-managed ElastiCache replication group for ${var.name}-${var.env}"
  number_cache_clusters         = var.redis_clusters
  node_type                     = var.redis_node_type
  automatic_failover_enabled    = var.redis_failover
  engine_version                = var.redis_version
  port                          = var.redis_port
  parameter_group_name          = "${var.redis_clusters == null ? aws_elasticache_parameter_group.redis_parameter_group_cluster[0].id : aws_elasticache_parameter_group.redis_parameter_group[0].id}"
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.id
  security_group_ids            = [aws_security_group.redis_security_group.id]
  apply_immediately             = var.apply_immediately
  maintenance_window            = var.redis_maintenance_window
  snapshot_window               = var.redis_snapshot_window
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
  availability_zones            = var.availability_zones
  
  dynamic "cluster_mode" {
    for_each = var.redis_clusters == null ? [var.redis_clusters] : []
    content {
      replicas_per_node_group = var.replicas_per_node_group
      num_node_groups = var.num_node_groups
    }
  }

  tags = merge(
    {
      "Name" = format(
        "tf-elasticache-%s-%s",
        var.name,
        lookup(data.aws_vpc.vpc.tags, "Name", ""),
      )
    },
    var.tags,
  )
}

### parameter group for cluster_mode disabled redis

resource "aws_elasticache_parameter_group" "redis_parameter_group" {

  count = "${var.redis_clusters == null ? 0 :1}"

  # tf-redis-sc-api-queue-dev
  name = "tf-redis-${var.name}-${var.env}"

  description = "Terraform-managed ElastiCache parameter group for ${var.name}-${var.env}"

  # Strip the patch version from redis_version var
  family = "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}"


  dynamic "parameter" {

    for_each = var.redis_parameters
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

### parameter group for cluster_mode enabled redis

resource "aws_elasticache_parameter_group" "redis_parameter_group_cluster" {

  count = "${var.redis_clusters == null ? 1 :0}"
  # tf-redis-sc-api-queue-dev
  name = "tf-redis-${var.name}-${var.env}"

  description = "Terraform-managed ElastiCache parameter group for ${var.name}-${var.env}"

  # Strip the patch version from redis_version var
  family = "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  dynamic "parameter" {

    for_each = var.redis_parameters
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "tf-redis-${var.name}-${var.env}"
  subnet_ids = var.subnets
}
