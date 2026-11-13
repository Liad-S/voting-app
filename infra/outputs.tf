output "redis_endpoint" {
  description = "Address of the ElastiCache Redis node"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "db_endpoint" {
  description = "Address of the RDS Postgres instance"
  value       = aws_db_instance.db.address
}

output "vote_url" {
  description = "URL of the vote page"
  value       = "http://${aws_lb.main.dns_name}"
}

output "result_url" {
  description = "URL of the result page"
  value       = "http://${aws_lb.main.dns_name}:8080"
}
