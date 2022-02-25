//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway

# add vm behind app gw
# manually deploy app gw and test config
# remove load balancer rule for 80 - still need load balancer for ssh?

locals {
  gw_name           = "gateway1"
  fe_port_name      = "fe-port"
  fe_ip_config_name = "fe-ipconfig"
  protocol          = "Http"
  listener_name     = "listener01"
}


resource "azurerm_application_gateway" "this" {
  name                = var.agw_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    name     = "Standard_Small"
    tier     = "Standard_v2"
    capacity = 1
  }
  gateway_ip_configuration {
    name      = local.gw_name
    subnet_id = azurerm_subnet.this[1].id
  }
  frontend_port {
    name = local.fe_port_name
    port = 80
  }
  frontend_ip_configuration {
    name = local.fe_ip_config_name
  }
  backend_address_pool {
    name         = "be-pool"
    ip_addresses = azurerm_linux_virtual_machine.vm.private_ip_addresses
  }
  backend_http_settings {
    cookie_based_affinity = "Enabled"
    name                  = "be-http-setting"
    port                  = 80
    protocol              = local.protocol
    request_timeout       = 30
  }
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.fe_ip_config_name
    frontend_port_name             = local.fe_port_name
    protocol                       = local.protocol
  }
  request_routing_rule {
    name               = "rule1"
    rule_type          = "Basic"
    http_listener_name = local.listener_name
  }
}