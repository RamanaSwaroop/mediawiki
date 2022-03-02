module "rg" {
  source                  = "./modules/rg"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  resource_tags           = var.resource_tags
}

module "network" {
  source = "./modules/network"
  depends_on = [
    module.rg
  ]
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
  nsg                = var.nsg
  lb_name            = var.lb_name
}

module "vm" {
  source = "./modules/vm"
  depends_on = [
    module.rg,
    module.network
  ]
  vm_name     = var.vm_name
  vm_size     = var.vm_size
  vm_image_id = var.vm_image_id
  vm_username = var.vm_username
  script_path = var.script_path
  image_rg    = var.image_rg
  vm_subnet   = var.vm_subnet
}

module "app-gw" {
  source = "./modules/appgw"
  depends_on = [
    module.rg,
    module.network,
    module.vm
  ]
  agw_name   = var.agw_name
  agw_subnet = var.agw_subnet
}