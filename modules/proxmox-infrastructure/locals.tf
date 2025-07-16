# =============================================================================
# LOCAL VALUES FOR NODE CONFIGURATION CALCULATIONS
# =============================================================================

locals {
  # Flatten node configurations for iteration across multiple Proxmox nodes
  nodes = flatten([
    for node_name, config in var.node_distribution : [
      # Control plane nodes for this Proxmox node
      for i in range(config.controlplane_count) : {
        key               = "controlplane-${node_name}-${i}"
        type              = "controlplane"
        proxmox_node_name = node_name
        name_prefix       = "${var.cluster_config.name}-ctrl"
        vm_id_min         = var.vm_id_ranges.controlplane_min
        vm_id_max         = var.vm_id_ranges.controlplane_max
        ip_start          = var.node_config.controlplane_ip_start
        template_key      = "controlplane"
        index             = i
        # Calculate global index for IP assignment
        global_index = sum(concat([0], [
          for other_node_name, other_config in var.node_distribution :
          other_config.controlplane_count if index(keys(var.node_distribution), other_node_name) < index(keys(var.node_distribution), node_name)
        ])) + i
      }
    ] if config.controlplane_count > 0
  ])

  # Flatten worker nodes separately
  worker_nodes = flatten([
    for node_name, config in var.node_distribution : [
      for i in range(config.worker_count) : {
        key               = "worker-${node_name}-${i}"
        type              = "worker"
        proxmox_node_name = node_name
        name_prefix       = "${var.cluster_config.name}-node"
        vm_id_min         = var.vm_id_ranges.worker_min
        vm_id_max         = var.vm_id_ranges.worker_max
        ip_start          = var.node_config.worker_ip_start
        template_key      = "worker"
        index             = i
        # Calculate global index for IP assignment
        global_index = sum(concat([0], [
          for other_node_name, other_config in var.node_distribution :
          other_config.worker_count if index(keys(var.node_distribution), other_node_name) < index(keys(var.node_distribution), node_name)
        ])) + i
      }
    ] if config.worker_count > 0
  ])

  # Combine all nodes
  all_nodes = concat(local.nodes, local.worker_nodes)

  # Calculate IP addresses when not using DHCP
  node_ips = var.network_config.enable_dhcp ? {} : {
    for node in local.all_nodes :
    node.key => cidrhost(var.network_config.cidr, node.ip_start + node.global_index)
  }

  # Convert nodes list to map for resources that require for_each
  nodes_map = {
    for node in local.all_nodes :
    node.key => {
      type              = node.type
      proxmox_node_name = node.proxmox_node_name
      name_prefix       = node.name_prefix
      vm_id_min         = node.vm_id_min
      vm_id_max         = node.vm_id_max
      ip_start          = node.ip_start
      template_key      = node.template_key
      index             = node.index
      global_index      = node.global_index
      node              = node.proxmox_node_name
    }
  }
}
