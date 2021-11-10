variable "name" {
  description = "resource name"
  type        = string
}

variable "env" {
  description = "Environment name e.g. dev, test, prod"
  type        = string
}

variable "resource_type" {
  description = "The Resource type e.g. vnet, appi, func, etc.."
  type        = string
}

variable "location" {
  description = "The location e.g. uksouth, ukwest, etc.."
  type        = string  
}

variable "separator" {
  description = "The separator used in the name e.g. - or empty if for resources that cannot use a separator"
  type        = string
}