/* This terraform configuration creates storage account on Azure & creates a container for storing virtual machine HD image */

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "jenkins_storage" {
  #name                     = "${var.config["storage_account_name"]}"
  name                     = "tfsta${lower(random_id.storage_account.hex)}"
  resource_group_name      = "${azurerm_resource_group.res_group.name}"
  location                 = "${azurerm_resource_group.res_group.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
