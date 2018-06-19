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
    "storage_account_name" = "teststgactjen001"
    "container_name"       = "vhds"
    "share_name"           = "hashare"

    # Load Balancer settings
    "lb_pip_name"    = "lb-pip"
    "lb_ip_dns_name" = ""

    # Availablity Set settings
    "avail_set1_name" = "adavailabilityset"
    "avail_set2_name" = "sqlavailabilityset"

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