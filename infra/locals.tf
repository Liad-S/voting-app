locals {
  # Prefix of every resource name, for example "liad-dev"
  name = "${var.name_prefix}-${var.env}"
}
