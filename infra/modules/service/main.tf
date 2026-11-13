data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.image
      essential = true

      # A port mapping only when the service has a port
      portMappings = var.container_port == null ? [] : [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # map in the module -> list of {name, value} in the JSON
      environment = [for k, v in var.environment : { name = k, value = v }]

      # list of {name, valueFrom}: ECS reads the value from Secrets Manager at start
      secrets = [for k, v in var.secrets : { name = k, valueFrom = v }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true # no NAT: a public IP is how the task reaches ECR
  }

  # A bad version rolls back by itself
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Keep all current tasks until the new ones are healthy (no downtime)
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  # terraform apply waits until the deployment is finished: new version up, or rolled back
  wait_for_steady_state = true

  # A load_balancer block only when there is a target group
  dynamic "load_balancer" {
    for_each = var.target_group_arn == null ? [] : [1]

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.name
      container_port   = var.container_port
    }
  }
}
