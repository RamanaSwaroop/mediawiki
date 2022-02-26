//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway

# add vm behind app gw
# manually deploy app gw and test config
# remove load balancer rule for 80 - still need load balancer for ssh?

locals {
  gw_name                    = "gateway1"
  fe_port_name               = "fe-port"
  fe_ip_config_name          = "fe-ipconfig"
  protocol                   = "Http"
  listener_name              = "listener01"
  backend_http_settings_name = "be-http-setting"
  backend_address_pool_name  = "be-pool"
  probe_name                 = "probe1"
}

data "azurerm_subnet" "agw" {
  name                 = var.agw_subnet
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
  depends_on = [
    azurerm_subnet.this,
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_application_gateway" "this" {
  name                = var.agw_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }
  gateway_ip_configuration {
    name      = local.gw_name
    subnet_id = data.azurerm_subnet.agw.id
  }
  frontend_port {
    name = local.fe_port_name
    port = 80
  }
  frontend_ip_configuration {
    name                 = local.fe_ip_config_name
    public_ip_address_id = azurerm_public_ip.agw-pip.id
  }
  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = azurerm_linux_virtual_machine.vm.private_ip_addresses
  }
  backend_http_settings {
    cookie_based_affinity = "Enabled"
    name                  = local.backend_http_settings_name
    port                  = 80
    protocol              = local.protocol
    request_timeout       = 30
    probe_name            = local.probe_name
  }
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.fe_ip_config_name
    frontend_port_name             = local.fe_port_name
    protocol                       = local.protocol
  }
  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_http_settings_name = local.backend_http_settings_name
    backend_address_pool_name  = local.backend_address_pool_name
  }
  probe {
    name                = local.probe_name
    interval            = 30
    protocol            = "Http"
    path                = "/mediawiki/"
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"
  }
}