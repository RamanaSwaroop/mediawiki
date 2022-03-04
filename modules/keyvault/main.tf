
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "this" {
  name                   = var.kv_name
  location               = data.azurerm_resource_group.this.location
  resource_group_name    = data.azurerm_resource_group.this.name
  tenant_id              = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment = true
  sku_name               = "standard"
  access_policy = [{
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    application_id     = data.azurerm_client_config.current.client_id
    key_permissions    = []
    certificate_permissions = []
    storage_permissions = []
    secret_permissions = ["get", "set", "list", "delete", "recover", "purge"]
  }]
}
