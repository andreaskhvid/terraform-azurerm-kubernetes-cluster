## define variables here
variable "resource_group_name" {
  type        = string
  description = "The resource group to place the resource in."
  nullable    = false
}

variable "location" {
  type        = string
  description = "The region to place the resource in."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resource."
  default     = null
}

variable "account_tier" {
  type = string
}

variable "account_replication_type" {
  type = string
}
