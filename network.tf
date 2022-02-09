data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = data.azurerm_resource_group.rg.tags
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = var.subnet_address_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create NSG rule
resource "azurerm_network_security_rule" "rule1" {
  name                        = "IBA-Internet-VNET-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "rule2" {
  name                        = "IBA-Internet-VNET-SSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create Public IP
resource "azurerm_public_ip" "pip" {
  name                = "fe-pip"
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Public Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  resource_group_name = data.azurerm_resource_group.rg.name
  frontend_ip_configuration {
    name                 = "fe-ipconfig"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create backend pool for load balancer
resource "azurerm_lb_backend_address_pool" "lb-be-pool" {
  name            = "blue-be"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_backend_address_pool" "lb-be-pool-2" {
  name            = "green-be"
  loadbalancer_id = azurerm_lb.lb.id
}

# Create health probe
resource "azurerm_lb_probe" "probe1" {
  name                = "http-probe"
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = "80"
  protocol            = "http"
  request_path        = "/mediawiki/"
}

resource "azurerm_lb_probe" "probe2" {
  name                = "sshp-probe"
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = "22"
  protocol            = "Tcp"
}

# Create inbound LB rule
resource "azurerm_lb_rule" "rule1" {
  name                           = "http-rule"
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe1.id
  frontend_ip_configuration_name = "fe-ipconfig"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-be-pool.id]
}

resource "azurerm_lb_rule" "rule2" {
  name                           = "ssh-rule"
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe2.id
  frontend_ip_configuration_name = "fe-ipconfig"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-be-pool.id]
}

# Create outbound LB rule - probably not required.
