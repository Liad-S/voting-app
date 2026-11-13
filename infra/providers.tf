terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Empty on purpose: bucket, key, region and use_lockfile come from -backend-config
  backend "s3" {}
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "voting-app"
      Environment = var.env
      Owner       = var.name_prefix
    }
  }
}
