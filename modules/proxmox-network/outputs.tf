output "resource_pool_id" {
  description = "ID of the created resource pool"
  value       = proxmox_virtual_environment_pool.cluster.pool_id
}

output "bridge_name" {
  description = "Name of the Linux bridge (either existing or created)"
  value = var.network_config.create_bridge ? (
    var.network_config.bridge_name != null ?
    var.network_config.bridge_name :
    "vmbr${var.network_config.bridge_id}"
  ) : var.network_config.bridge

}

output "vlan_id" {
  description = "VLAN ID if VLAN was created"
  value       = var.network_config.vlan_id
}

output "network_cidr" {
  description = "CIDR of the cluster network"
  value       = var.network_config.cidr
}

output "security_group_name" {
  description = "Name of the firewall security group if created"
  value       = var.network_config.enable_firewall ? "${var.cluster_config.name}-talos" : null
}

output "network_configuration" {
  description = "Complete network configuration for use by other modules"
  value = {
    resource_pool_id = proxmox_virtual_environment_pool.cluster.pool_id
    bridge_name = var.network_config.create_bridge ? (
      var.network_config.bridge_name != null ?
      var.network_config.bridge_name :
      "vmbr${var.network_config.bridge_id}"
    ) : var.network_config.bridge
    vlan_id             = var.network_config.vlan_id
    cidr                = var.network_config.cidr
    gateway             = var.network_config.gateway
    security_group_name = var.network_config.enable_firewall ? "${var.cluster_config.name}-talos" : null
  }
}
