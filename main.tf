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
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  nsg                 = var.nsg
  lb_name             = var.lb_name
  vm_pip              = var.vm_pip
  agw-pip             = var.agw_pip
}

module "vm" {
  source = "./modules/vm"
  depends_on = [
    module.rg,
    module.network
  ]
  resource_group_name = var.resource_group_name
  resource_tags       = var.resource_tags
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  vm_image_id         = var.vm_image_id
  vm_username         = var.vm_username
  script_path         = var.script_path
  image_rg            = var.image_rg
  vnet_name           = var.vnet_name
  vm_subnet           = var.vm_subnet
  lb_name             = var.lb_name
}

module "app-gw" {
  source = "./modules/appgw"
  depends_on = [
    module.rg,
    module.network,
    module.vm
  ]
  agw_name            = var.agw_name
  agw_subnet          = var.agw_subnet
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  vm_name             = var.vm_name
  agw_pip             = var.agw_pip
}

module "mariadb" {
  source = "./modules/mariadb"
  depends_on = [
    module.rg,
    module.network
  ]
  resource_group_name = var.resource_group_name
  mariadb_server_name = var.mariadb_server_name
  mariadb_name        = var.mariadb_name
}