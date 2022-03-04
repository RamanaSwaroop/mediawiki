variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "nsg" {
  type = list(object({
    name = string
    security_rules = list(object({
      name                       = string
      protocol                   = string
      direction                  = string
      access                     = string
      priority                   = number
      source_port_range          = string
      source_address_prefix      = string
      destination_port_range     = string
      destination_address_prefix = string
    }))
  }))
}

variable "lb_name" {
  type = string
}

variable "vm_pip" {
  type = string
}
