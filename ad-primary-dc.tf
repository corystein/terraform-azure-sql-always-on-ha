resource "azurerm_public_ip" "ad-primary-dc-pip" {
  name                         = "ad-primary-dc-pip"
  location                     = "${azurerm_resource_group.res_group.location}"
  resource_group_name          = "${azurerm_resource_group.res_group.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "ad-primary-dc-pip-nic" {
  name                = "ad-primary-dc-pip-nic"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  ip_configuration {
    name = "ipconfig1"

    #private_ip_address_allocation = "static"
    private_ip_address_allocation           = "dynamic"
    subnet_id                               = "${azurerm_subnet.subnet1.id}"
    public_ip_address_id                    = "${azurerm_public_ip.ad-primary-dc-pip.id}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.loadbalancer_backend.id}"]

    #load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_rule.lb_rule.id}"]

    #private_ip_address            = "${var.config["jenkins_master_primary_ip_address"]}"
  }
}

resource "azurerm_virtual_machine" "ad-primary-dc-pip-vm" {
  name                  = "ad-primary-dc"
  resource_group_name   = "${azurerm_resource_group.res_group.name}"
  location              = "${azurerm_resource_group.res_group.location}"
  availability_set_id   = "${azurerm_availability_set.avail_set1.id}"
  network_interface_ids = ["${azurerm_network_interface.ad-primary-dc-pip-nic.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name = "ad-primary-dc-osdisk"

    #vhd_uri           = "${azurerm_storage_account.jenkins_storage.primary_blob_endpoint}${azurerm_storage_container.jenkins_cont.name}/osdisk-1.vhd"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    disk_size_gb      = "128"
  }
  os_profile {
    computer_name  = "ad-primary-dc"
    admin_username = "DomainAdmin"
    admin_password = "Contoso!0000"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
  }
}

/*
#Configure PDC
resource "azurerm_virtual_machine_extension" "create_ad_forest_extension" {
  name                = "${format("%s-CreateADForest", var.config["pdc_vm_name"])}"
  resource_group_name = "${azurerm_resource_group.quickstartad.name}"
  location            = "${azurerm_resource_group.quickstartad.location}"

  virtual_machine_name       = "${azurerm_virtual_machine.pdc_virtual_machine.name}"
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.21"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
		{
			"ModulesUrl": "${var.config["asset_location"]}${var.config["create_pdc_script_path"]}",
			"ConfigurationFunction": "${var.config["ad_pdc_config_function"]}\\CreateADPDC",
      "Properties": {
        "DomainName": "${var.domain_name}",
        "AdminCreds": {
            "UserName": "${var.admin_username}",
            "Password": "PrivateSettingsRef:AdminPassword"
        }
      }
		}
  SETTINGS

  protected_settings = <<SETTINGS
    {
      "Items": {
        "AdminPassword": "${var.admin_password}"
      }
    }
  SETTINGS
}

#Update vNet with the new DNS Server once primary DC has been createad
resource "azurerm_virtual_network" "adha_vnet_with_dns" {
  depends_on          = ["azurerm_virtual_machine_extension.create_ad_forest_extension"]
  name                = "${var.config["vnet_name"]}"
  resource_group_name = "${azurerm_resource_group.quickstartad.name}"
  location            = "${azurerm_resource_group.quickstartad.location}"
  address_space       = ["${var.config["vnet_address_range"]}"]
  dns_servers         = ["${var.config["pdc_nic_ip_address"]}"]

  subnet {
    name           = "${var.config["subnet_name"]}"
    address_prefix = "${var.config["subnet_address_range"]}"
  }
}
*/

