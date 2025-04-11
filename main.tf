resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-${var.environment}-aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.default_node_pool.name
    node_count      = var.default_node_pool.count
    vm_size         = var.default_node_pool.vm_size
    os_disk_size_gb = var.default_node_pool.os_disk_size_gb
    max_pods        = var.default_node_pool.max_pods
    vnet_subnet_id  = var.nodes_subnet_id
    # enable_auto_scaling   = var.default_node_pool.enable_auto_scaling
    min_count = var.default_node_pool.min_count
    max_count = var.default_node_pool.max_count
    # enable_node_public_ip = var.default_node_pool.enable_node_public_ip
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  private_cluster_enabled = var.private_cluster_enabled

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.admin_objects_ids != null ? [1] : []
    content {
      #   managed                = true
      admin_group_object_ids = var.admin_objects_ids
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}