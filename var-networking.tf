variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_name" {
  type = string
}

variable "subnet_address_prefix" {
  type = list(string)
}

variable "nsg_name" {
  type = string
}

variable "lb_name" {
  type = string
}
