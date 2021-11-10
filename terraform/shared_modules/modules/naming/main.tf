locals {
  env              = var.env
  resource_type    = var.resource_type
  location         = var.location
  separated_prefix = var.resource_type == "" ? "${var.env}" : "${var.env}${var.separator}${var.resource_type}"
  separated_name = "${var.separator}${var.name}${var.separator}"
}

locals {
  result = var.separator == "" ? replace(lower("${local.separated_prefix}${local.separated_name}${local.location}"), "-", "") : "${local.separated_prefix}${local.separated_name}${local.location}"
}