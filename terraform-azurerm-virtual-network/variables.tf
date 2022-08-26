## define variables here
variable "name" {
  type = string
  description = "The name of the virtual network."
  nullable = false
}

variable "location" {
  type        = string
  description = "The location/region where the virtual network is created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = null
}

variable "address_space" {
  type = list(string)
  description = "The address space that is used the virtual network. You can supply more than one address space."
  nullable = false
}

variable "dns_servers" {
  type = list(string)
  description = "List of IP addresses of DNS servers"
  default = null
}

variable "subnets" {
  type = map(any)
  nullable = false
}