variable "resource_group" {
  description = "resource group name"
  type        = string
}

variable "resource_group_location" {
  description = "resource group location"
  type        = string
}

variable "env" {
  description = "Environment name e.g. dev, test, prod"
  type        = string
}

variable "appName" {
  description = "The name of the application e.g. myapp"
  type        = string
}

variable "appInsightsType" {
  description = "The type of application e.g. ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web"
  type        = string
  default     = "web"
  validation {
    condition     = contains(["ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store", "web"], var.appInsightsType)
    error_message = "Argument 'appInsightsType' must one of 'ios', 'java', 'MobileCenter', 'Node.JS', 'other', 'phone', 'store', 'web'."
  }    
}

variable "funcWorkerRuntime" {
 description = "The function worker runtime e.g. node, dotnet, dotnet-isolated"
 default = "dotnet-isolated"
 type        = string
  validation {
    condition     = contains(["node", "dotnet", "dotnet-isolated", "java", "powershell", "python"], var.funcWorkerRuntime)
    error_message = "Argument 'funcWorkerRuntime' must one of 'node', 'dotnet', 'dotnet-isolated', 'java', 'powershell', 'python'."
  } 
}

variable "funcVersion" {
    description = "The function version e.g. ~3, ~4, etc."
    type        = string
    default     = "~3"
}

variable "dotnetVersion" {
  description = "The dotnet version in Terraform v4.0 for .NET Core up to 3.1 and v5.0 or v6.0"
  type        = string
  default     = "v5.0"
}

variable "additionalFuncAppSettings" {
  description = "Additional Application Settings"
  type        = map(string)
}

variable "tags" {
  description = "The tags for the resources"
  type        = map(string)
}