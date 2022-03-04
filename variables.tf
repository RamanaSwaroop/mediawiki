variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "resource_tags" {
  type = map(string)
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

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_image_id" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "script_path" {
  type = string
}

variable "image_rg" {
  type = string
}

variable "vm_subnet" {
  type = string
}

variable "agw_name" {
  type = string
}

variable "agw_subnet" {
  type = string
}

variable "vm_pip" {
  type = string
}

variable "agw_pip" {
  type = string
}

variable "mariadb_server_name" {
  type = string
}

variable "mariadb_name" {
  type = string
}

variable "kv_name" {
  type = string
}

variable "agw_sku" {
  type = object({
    name = string
    tier = string
  })
}
