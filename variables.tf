variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "tenant_id" {}

variable "config" {
  type = "map"

  default {
    # Resource Group settings
    "resource_group" = "SQL-HA-RG"
    "location"       = "East US"

    # Network Security Group settings
    "security_group_name" = "TEST-NSG-SQLHA-001"

    # Network settings
    "root_domain_name"              = "contoso.com"
    "vnet_name"                     = "autohaVNET"
    "vnet_address_range"            = "10.0.0.0/16"
    "subnet1_name"                  = "admin"
    "subnet1_address_range"         = "10.0.0.0/24"
    "subnet2_name"                  = "sqlsubnet"
    "subnet2_address_range"         = "10.0.1.0/24"
    "network_public_ipaddress_type" = "static"

    # Storage Account settings
    #"storage_account_name" = "teststgactjen001"
    "container_name" = "scripts"

    #"share_name"           = "hashare"

    # Load Balancer settings
    "lb_pip_name"    = "lb-pip"
    "lb_ip_dns_name" = ""

    # Availablity Set settings
    #"avail_set1_name" = "adavailabilityset"
    #"avail_set2_name" = "sqlavailabilityset"

    # AD Setup Scripts
    "domain_name"               = "corp.contoso.com"
    "admin_username"            = "domainadmin"
    "admin_password"            = "Contoso!0000"
    "asset_location"            = "https://demotest001.blob.core.windows.net/activedirectory"
    "create_pdc_script_path"    = "/CreateADPDC.zip"
    "prepare_bdc_script_path"   = "/PrepareADBDC.zip"
    "configure_bdc_script_path" = "/ConfigureADBDC.zip"
    "ad_pdc_config_function"    = "CreateADPDC.ps1"
    "ad_bdc_prepare_function"   = "PrepareADBDC.ps1"
    "ad_bdc_config_function"    = "ConfigureADBDC.ps1"
    ######################################
    # Virtual Machine settings
    ######################################
    # AD Primary
    "ad_primary_dc_vmname" = "ad-primary-dc"

    ######################################

    "vm_winrm_port" = "5986"

    /*
    # Virtual Machine settings
    "jenkins_master_primary_vmname"       = "TESTJENMSTVM001"
    "jenkins_master_secondary_vmname"     = "TESTJENMSTVM002"
    "jenkins_master_vmsize"               = "Standard_DS1_v2"
    "jenkins_master_vm_image_publisher"   = "OpenLogic"
    "jenkins_master_vm_image_offer"       = "CentOS"
    "jenkins_master_vm_image_sku"         = "7.3"
    "jenkins_master_vm_image_version"     = "latest"
    "availability_set_name"               = "jenkinsAvailabilitySet"
    "jenkins_master_primary_ip_address"   = "10.199.10.18"
    "jenkins_master_secondary_ip_address" = "10.199.10.19"
    "jenkins_master_primrary_nic"         = "jenkins_master_primary_nic"
    "jenkins_master_secondary_nic"        = "jenkins_master_secondary_nic"
    "os_name"                             = "centosJenkins01"
    "vm_username"                         = "jenkins_admin"
    "vm_password"                         = "P@ssword12345"
    */
  }
}

variable "azure_region" {
  description = "Azure Region for all resources"
  default     = "eastus"
}

variable "azure_dns_suffix" {
  description = "Azure DNS suffix for the Public IP"
  default     = "cloudapp.azure.com"
}

#Null resource to make the VM intermediate varable - probably not the right way to do this
resource "null_resource" "intermediates" {
  triggers = {
    full_vm_dns_name = "${var.config["ad_primary_dc_vmname"]}.${var.azure_region}.${var.azure_dns_suffix}"
  }
}

output "full_vm_dns_name" {
  value = "${null_resource.intermediates.triggers.full_vm_dns_name}"
}
