module "rg" {
  source   = "./modules/rg"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  resource_tags     = var.resource_tags
}

