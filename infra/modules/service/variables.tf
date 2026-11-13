variable "name" {
  description = "Name of the service, for example liad-dev-vote. Used for the log group, task family, service and container"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "image" {
  description = "Full image reference: <ECR repository URL>:<tag>"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the task execution role (pulls the image, writes logs, reads secrets)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets of the tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups of the tasks"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of tasks"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Fargate CPU units. With 256 the memory must be 512, 1024 or 2048"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory in MB"
  type        = number
  default     = 512
}

variable "environment" {
  description = "Plain environment variables of the container (name => value). Never put a secret here"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets of the container (name => ARN of the Secrets Manager secret)"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Port of the container. null = no port mapping (worker)"
  type        = number
  default     = null
}

variable "target_group_arn" {
  description = "Target group to register the tasks in. null = not behind the load balancer (worker)"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Days to keep the logs"
  type        = number
  default     = 7
}
