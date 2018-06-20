/* This terraform configuration creates storage account on Azure & creates a container for storing virtual machine HD image */

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account" {
  #name                     = "${var.config["storage_account_name"]}"
  name                     = "tfsta${lower(random_id.storage_account.hex)}"
  resource_group_name      = "${azurerm_resource_group.res_group.name}"
  location                 = "${azurerm_resource_group.res_group.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "${var.config["container_name"]}"
  resource_group_name   = "${azurerm_resource_group.res_group.name}"
  storage_account_name  = "${azurerm_storage_account.storage_account.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "blobobject" {
  depends_on             = ["azurerm_storage_container.storage_container"]
  name                   = "scripts"
  resource_group_name    = "${azurerm_resource_group.res_group.name}"
  storage_account_name   = "${azurerm_storage_account.storage_account.name}"
  storage_container_name = "${azurerm_storage_container.storage_container.name}"
  source                 = "./scripts/*"
}
