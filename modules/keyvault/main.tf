
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "kv" {
  name                   = var.kv_name
  location               = data.azurerm_resource_group.rg.location
  resource_group_name    = data.azurerm_resource_group.rg.name
  tenant_id              = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment = true
  sku_name               = "standard"
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["get", "set", "list", "delete", "recover", "purge"]
}