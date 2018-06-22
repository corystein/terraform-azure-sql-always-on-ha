resource "azurerm_public_ip" "ad-primary-dc-pip" {
  name                = "ad-primary-dc-pip"
  location            = "${azurerm_resource_group.res_group.location}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"

  #public_ip_address_allocation = "static"

  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.config["ad_primary_dc_vmname"]}"

  #sku                          = "Standard"
}

resource "azurerm_network_interface" "ad-primary-dc-nic" {
  name                = "ad-primary-dc-nic"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  ip_configuration {
    name = "ipconfig1"

    #private_ip_address_allocation = "static"
    private_ip_address_allocation = "dynamic"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    public_ip_address_id          = "${azurerm_public_ip.ad-primary-dc-pip.id}"

    #load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.loadbalancer_backend.id}"]

    #load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_rule.lb_rule.id}"]

    #private_ip_address            = "${var.config["jenkins_master_primary_ip_address"]}"
  }
}

/*
locals {
  virtual_machine_name = "${var.prefix}-dc"
  virtual_machine_fqdn = "${local.virtual_machine_name}.${var.active_directory_domain}"
  custom_data_params   = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data_content  = "${local.custom_data_params} ${file("${path.module}/files/winrm.ps1")}"
}
*/

resource "azurerm_virtual_machine" "ad-primary-dc-vm" {
  name                = "ad-primary-dc"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  #availability_set_id   = "${azurerm_availability_set.adavailabilityset.id}"
  network_interface_ids = ["${azurerm_network_interface.ad-primary-dc-nic.id}"]
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

    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    disk_size_gb      = "128"
  }
  os_profile {
    computer_name  = "${var.config["ad_primary_dc_vmname"]}"
    admin_username = "${var.config["admin_username"]}"
    admin_password = "${var.config["admin_password"]}"

    #custom_data    = "${file("${path.module}/files/winrm.ps1")}"
    #custom_data = "${base64encode(file("${path.module}/files/EnableWinRM.ps1"))}"

    #Include Deploy.PS1 with variables injected as custom_data
    #custom_data = "${base64encode("Param($RemoteHostName = \"${null_resource.intermediates.triggers.full_vm_dns_name}\", $ComputerName = \"${var.config["ad_primary_dc_vmname"]}\", $WinRmPort = ${var.config["vm_winrm_port"]}) ${file("${path.module}/files/Deploy.ps1")}")}"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.config["admin_password"]}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.config["admin_username"]}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("${path.module}/files/FirstLogonCommands.xml")}"
    }
  }
}

resource "null_resource" "remote-exec-ad-primary-dc" {
  provisioner "file" {
    connection {
      type = "winrm"

      #https    = false
      #insecure = true
      #port = "5985"
      host = "${azurerm_public_ip.ad-primary-dc-pip.fqdn}"

      user     = "${var.config["admin_username"]}"
      password = "${var.config["admin_password"]}"
      timeout  = "30s"
    }

    source      = "./scripts/"
    destination = "c:/scripts"
  }

  provisioner "local-exec" {
    command     = "Get-Date > completed.txt"
    interpreter = ["PowerShell", "-Command"]
    working_dir = "c:/scripts/ad"
  }

  depends_on = ["azurerm_virtual_machine.ad-primary-dc-vm"]
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
        "DomainName": "${var.config["domain_name"]}",
        "AdminCreds": {
            "UserName": "${var.config["admin_username"]}",
            "Password": "PrivateSettingsRef:${var.config["admin_username"]}"
        }
      }
		}
  SETTINGS
  
  
  protected_settings = <<SETTINGS
    {
      "Items": {
        "AdminPassword": "${var.config["admin_password"]}"
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

