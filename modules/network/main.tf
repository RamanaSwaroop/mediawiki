data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a virtual network
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = data.azurerm_resource_group.this.tags
}

# Create subnet
resource "azurerm_subnet" "this" {
  count                = length(var.subnets)
  name                 = var.subnets[count.index]["name"]
  resource_group_name  = data.azurerm_resource_group.this.name
  address_prefixes     = var.subnets[count.index]["address_prefixes"]
  virtual_network_name = azurerm_virtual_network.this.name
}

# Create NSG
resource "azurerm_network_security_group" "this" {
  count               = length(var.nsg)
  name                = var.nsg[count.index]["name"]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  dynamic "security_rule" {
    for_each = var.nsg[count.index]["security_rules"]
    content {
      name                       = security_rule.value["name"]
      protocol                   = coalesce(security_rule.value["protocol"], "Tcp")
      direction                  = security_rule.value["direction"]
      access                     = coalesce(security_rule.value["access"], "Allow")
      priority                   = security_rule.value["priority"]
      source_address_prefix      = lookup(security_rule.value, "source_address_prefix", null)
      destination_address_prefix = lookup(security_rule.value, "destination_address_prefix", null)
      source_port_range          = lookup(security_rule.value, "source_port_range", null)
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
    }
  }
}

# Assume each subnet as unique nsg
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = length(var.subnets)
  subnet_id                 = azurerm_subnet.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this[count.index].id
}

# Create Public IP
resource "azurerm_public_ip" "this" {
  name                = var.vm_pip
  location            = data.azurerm_resource_group.this.location
  sku                 = "Basic"
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Dynamic"
}

# Create Public Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = data.azurerm_resource_group.this.location
  sku                 = "Basic"
  resource_group_name = data.azurerm_resource_group.this.name
  frontend_ip_configuration {
    name                 = "fe-ipconfig"
    public_ip_address_id = azurerm_public_ip.this.id
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


resource "azurerm_lb_probe" "probe2" {
  name                = "sshp-probe"
  resource_group_name = data.azurerm_resource_group.this.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = "22"
  protocol            = "Tcp"
}


resource "azurerm_lb_rule" "rule2" {
  name                           = "ssh-rule"
  resource_group_name            = data.azurerm_resource_group.this.name
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe2.id
  frontend_ip_configuration_name = "fe-ipconfig"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-be-pool.id]
}
