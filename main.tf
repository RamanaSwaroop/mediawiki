

data "azurerm_client_config" "current" {}

data "azurerm_image" "this" {
  name                = var.vm_image_id
  resource_group_name = var.image_rg
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = join("", [var.vm_name, "-nic"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
  depends_on = [
    azurerm_lb.lb
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-bepool" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = azurerm_network_interface.nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-be-pool.id
  lifecycle {
    ignore_changes = [
      network_interface_id,
      backend_address_pool_id
    ]
  }
}

# Create Key Vault
resource "random_id" "rid" {
  keepers = {
    rg = var.resource_group_name
  }
  byte_length = 5
}

resource "azurerm_key_vault" "kv" {
  name                   = substr("wiki${random_id.rid.hex}kv", 0, 23)
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  tenant_id              = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment = true
  sku_name               = "standard"
}

# Generate SSH Key
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["get", "set", "list", "delete", "recover"]
}


# Store generated SSH key
resource "azurerm_key_vault_secret" "secret" {
  name         = join("-", [var.vm_name, "key"])
  value        = tls_private_key.private-key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.policy
  ]
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "(+%><"
}

resource "azurerm_key_vault_secret" "db-secret" {
  name         = "wiki"
  value        = random_password.this.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.policy
  ]
}

# Create VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.private-key.public_key_openssh
  }
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    name                 = join("", [var.vm_name, "-osdisk"])
    caching              = "ReadWrite"
    disk_size_gb         = 64
    storage_account_type = "Standard_LRS"
  }
  source_image_id = data.azurerm_image.this.id
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      admin_ssh_key,
      admin_username,
      network_interface_ids
    ]
  }
  tags = var.resource_tags
}

resource "azurerm_key_vault_access_policy" "vmpolicy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_virtual_machine.vm.identity[0].principal_id
  secret_permissions = ["get", "set", "list"]
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                       = "ConfigureApp"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = false
  settings                   = <<SETTINGS
  {
    "script": "${base64encode(templatefile("install.sh", { KEY_VAULT = "${azurerm_key_vault.kv.name}", db_root_password = "" }))}"
  }
  SETTINGS

  depends_on = [
    azurerm_key_vault_access_policy.vmpolicy,
    azurerm_key_vault_secret.db-secret
  ]
}

