## define variables here
variable "name" {
  type = string
  description = "The desired name for the resource."
  nullable = false
}

variable "location" {
  type = string
  description = "The region to place the resource in."
  nullable = false
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to resource."
  default = null
}