# The ECR repositories were created by the bootstrap. Terraform only reads them.
data "aws_ecr_repository" "service" {
  for_each = toset(["vote", "result", "worker"])

  name = "${var.name_prefix}-${each.key}"
}
