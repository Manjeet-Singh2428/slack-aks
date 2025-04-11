provider "azurerm" {
  features {}
 subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
}
data "azurerm_client_config" "current_client_config" {}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "slack-aks"
  environment = "test"
  label_order = ["name", "environment", ]
  location    = "Central India"
}

module "vnet" {
  source  = "clouddrove/vnet/azure"
  version = "1.0.4"

  name                = "slack"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.30.0.0/16"]
}

module "subnet" {
  source  = "clouddrove/subnet/azure"
  version = "1.2.0"
  # version = "1.2.0" #using release after 1.1.0

  name                 = "slack"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  #subnet
  subnet_names    = ["default"]
  subnet_prefixes = ["10.30.0.0/20"]

  # route_table
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}


module "aks" {
  source      = "../"
  name        = "slack-aks"
  environment = "test"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  kubernetes_version      = "1.29.2"
  private_cluster_enabled = false

  default_node_pool = {
    name                  = "akspool1"
    max_pods              = 200
    os_disk_size_gb       = 64
    vm_size               = "Standard_D2as_v4"
    count                 = 1
    enable_node_public_ip = false
    min_count             = 1
    max_count             = 2
    enable_auto_scaling   = true
  }

  nodes_subnet_id = module.subnet.default_subnet_id[0]
  cmk_enabled     = false
}