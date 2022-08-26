## define variables here
variable "workload_environment" {
  type = string
  description = "The environment of the workload."
  nullable = false
}

variable "workload_name" {
  type        = string
  description = "The name of the workload."
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

variable "address_space" {
  type = list(string)
  description = "The address space/subnet used by the default node pool."
  nullable = false
}

variable "node_count" {
  type = number
  description = "The amount of nodes in the default node pool."
  default = 1
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "The VM size used for the node pool."
  default     = "Standard_DS2_v2"
}

variable "capacity_reservation_group_id" {
  type = string
  description = "The ID of the capacity reservation group to allocate compute from."
  default = null
}
