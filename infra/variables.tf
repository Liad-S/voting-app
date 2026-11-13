variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env must be either \"dev\" or \"prod\"."
  }
}

variable "name_prefix" {
  description = "Prefix of every resource name (the same one used in the bootstrap)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", var.name_prefix))
    error_message = "name_prefix must be 1 to 12 characters: lowercase letters, digits and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR range of the VPC (a /16, for example 10.10.0.0/16)"
  type        = string
}

variable "image_tag" {
  description = "Tag of the container images in ECR (the git commit SHA in the pipeline)"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks per service"
  type        = number
}

variable "option_a" {
  description = "First choice on the vote page"
  type        = string
  default     = "ביבי"
}

variable "option_b" {
  description = "Second choice on the vote page"
  type        = string
  default     = "אייזנקוט"
}
