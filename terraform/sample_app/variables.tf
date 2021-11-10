variable "env" {
  description = "The environment e.g. dev, test, prod, etc."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The resources location"
  type        = string
  default     = "uksouth"
}

variable "appName" {
  description = "The application name"
  type        = string
  default     = "myapp"
}

variable "tags" {
  description = "The resources tags"
  type        = map(string)
  default     = {
    "project" = "myproject"
  }
}