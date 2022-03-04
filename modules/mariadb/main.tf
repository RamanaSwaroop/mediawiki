
data "azurerm_resource_group" "this"{
    name = var.resource_group_name
}

data "azurerm_key_vault" "this" {
  name = var.kv_name
  resource_group_name = var.resource_group_name
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "(+%><"
}

resource "azurerm_key_vault_secret" "this" {
  name         = "wiki"
  value        = random_password.this.result
  key_vault_id = data.azurerm_key_vault.kv.id
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_mariadb_server" "this" {
  name = var.mariadb_server_name
  location = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  administrator_login = "wikiadmin"
  administrator_login_password = azurerm_key_vault_secret.this.value

  sku_name = "B_Gen5_2"
  storage_mb = 5120
  version = 10.2

  auto_grow_enabled = true
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled = false
  ssl_enforcement_enabled = true

}

resource "azurerm_mariadb_database" "this" {
  name = var.mariadb_name
  resource_group_name = data.azurerm_resource_group.this.name
  server_name = azurerm_mariadb_server.this.name
  charset = "utf8"
  collation = "utf8_general_ci"
}