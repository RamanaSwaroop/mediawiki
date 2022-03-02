variable "resource_group_name" {
  type = string
}

variable "resource_tags" {
  type = map(string)
}

variable "vnet_name" {
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

variable "lb_name" {
  type = string
}