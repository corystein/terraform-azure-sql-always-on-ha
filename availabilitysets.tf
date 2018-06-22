/*
resource "azurerm_availability_set" "adavailabilityset" {
  name                         = "adavailabilityset"
  resource_group_name          = "${azurerm_resource_group.res_group.name}"
  location                     = "${azurerm_resource_group.res_group.location}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 5
  managed                      = true
}

resource "azurerm_availability_set" "sqlAvailabilitySet" {
  name                         = "sqlAvailabilitySet"
  resource_group_name          = "${azurerm_resource_group.res_group.name}"
  location                     = "${azurerm_resource_group.res_group.location}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}
*/

