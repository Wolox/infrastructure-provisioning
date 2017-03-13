variable "environment" {}
variable "application_name" {}

resource "aws_elasticache_cluster" "bar" {
    cluster_id = "${var.application_name}-${var.environment}"
    engine = "redis"
    node_type = "cache.t2.micro"
    port = 6379
    num_cache_nodes = 1
    security_group_ids = []
}
