output "resource_group_id" {
  value       = azurerm_resource_group.rg.id
  description = "Resource Group resource ID"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "VNET Resource ID"
}

output "vm_managed_id" {
  value = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}