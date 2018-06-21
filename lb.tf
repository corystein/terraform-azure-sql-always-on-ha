resource "azurerm_public_ip" "loadbalancer_pip" {
  name                = "${var.config["lb_pip_name"]}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"

  #public_ip_address_allocation = "dynamic"

  public_ip_address_allocation = "static"
  #domain_name_label            = "${var.config["lb_ip_dns_name"]}"
  sku = "Standard"
}

resource "azurerm_lb" "loadbalancer" {
  name                = "loadbalancer"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  location            = "${azurerm_resource_group.res_group.location}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "loadbalancer_frontend"
    public_ip_address_id = "${azurerm_public_ip.loadbalancer_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer_backend" {
  name                = "loadbalancer_backend"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
}

resource "azurerm_lb_probe" "loadbalancer_probe" {
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
}

/*
resource "azurerm_lb_rule" "lb_http_rule" {
  resource_group_name            = "${azurerm_resource_group.res_group.name}"
  loadbalancer_id                = "${azurerm_lb.jenkins_lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "jenkins_lb_frontend"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.jenkins_lb_backend.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_nat_rule" "lb_ssh_rule" {
  resource_group_name            = "${azurerm_resource_group.res_group.name}"
  loadbalancer_id                = "${azurerm_lb.jenkins_lb.id}"
  name                           = "SSH-VM-01"
  protocol                       = "tcp"
  frontend_port                  = "50001"
  backend_port                   = 22
  frontend_ip_configuration_name = "jenkins_lb_frontend"
  count                          = 2
}
*/

