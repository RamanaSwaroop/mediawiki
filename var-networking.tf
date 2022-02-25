variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "nsg" {
  type = map(object({
    name       = string
    subnet_ids = list(string)
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
  default = {}
}


# variable "subnet_name" {
#   type = string
# }

# variable "subnet_address_prefix" {
#   type = list(string)
# }

# variable "nsg_name" {
#   type = string
# }

variable "lb_name" {
  type = string
}
