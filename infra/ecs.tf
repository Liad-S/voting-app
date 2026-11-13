resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"
}

locals {
  repo_url = { for k, r in data.aws_ecr_repository.service : k => r.repository_url }

  redis_host = aws_elasticache_cluster.redis.cache_nodes[0].address

  # Connection settings of the database, shared by result and worker
  db_env = {
    DB_HOST = aws_db_instance.db.address
    DB_PORT = tostring(aws_db_instance.db.port)
    DB_USER = aws_db_instance.db.username
    DB_NAME = aws_db_instance.db.db_name
    DB_SSL  = "true" # RDS Postgres 15+ refuses connections without TLS
  }

  # The password is NOT in environment: ECS reads it from Secrets Manager (D4)
  db_secrets = {
    DB_PASSWORD = aws_secretsmanager_secret.db_password.arn
  }
}

module "vote" {
  source = "./modules/service"

  name               = "${local.name}-vote"
  cluster_id         = aws_ecs_cluster.main.id
  image              = "${local.repo_url["vote"]}:${var.image_tag}"
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = [for s in aws_subnet.public : s.id]
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count
  container_port     = 80
  target_group_arn   = aws_lb_target_group.vote.arn

  environment = {
    REDIS_HOST = local.redis_host
    OPTION_A   = var.option_a
    OPTION_B   = var.option_b
  }

  # The service cannot be created before the listener exists
  depends_on = [aws_lb_listener.vote]
}

module "result" {
  source = "./modules/service"

  name               = "${local.name}-result"
  cluster_id         = aws_ecs_cluster.main.id
  image              = "${local.repo_url["result"]}:${var.image_tag}"
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = [for s in aws_subnet.public : s.id]
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count
  container_port     = 80
  target_group_arn   = aws_lb_target_group.result.arn

  environment = local.db_env
  secrets     = local.db_secrets

  depends_on = [aws_lb_listener.result]
}

# worker: no port, no target group, not behind the load balancer (L3)
module "worker" {
  source = "./modules/service"

  name               = "${local.name}-worker"
  cluster_id         = aws_ecs_cluster.main.id
  image              = "${local.repo_url["worker"]}:${var.image_tag}"
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = [for s in aws_subnet.public : s.id]
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count

  environment = merge({ REDIS_HOST = local.redis_host }, local.db_env)
  secrets     = local.db_secrets
}
