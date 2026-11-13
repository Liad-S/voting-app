output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "task_definition_arn" {
  description = "ARN of the task definition revision"
  value       = aws_ecs_task_definition.this.arn
}
