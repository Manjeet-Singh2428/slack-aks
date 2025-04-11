variable "name" {
  type        = string
  description = "Base name for resources"
}

variable "environment" {
  type        = string
  description = "Environment tag"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "Enable private cluster"
}

variable "default_node_pool" {
  type = object({
    name                  = string
    count                 = number
    vm_size               = string
    os_disk_size_gb       = number
    max_pods              = number
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    enable_node_public_ip = bool
  })
  description = "Default node pool configuration"
}

variable "nodes_subnet_id" {
  type        = string
  description = "Subnet ID for nodes"
}

variable "admin_objects_ids" {
  type        = list(string)
  default     = null
  description = "Azure AD group IDs for cluster admin access"
}

variable "cmk_enabled" {
  type        = bool
  default     = false
  description = "Enable customer-managed keys"
}