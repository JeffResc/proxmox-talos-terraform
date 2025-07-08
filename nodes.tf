# Node configuration
locals {
  # Calculate total counts for each node type
  total_controlplane_count = sum([for node_name, config in var.node_distribution : config.controlplane_count])
  total_worker_count       = sum([for node_name, config in var.node_distribution : config.worker_count])

  # Flatten node configurations for iteration across multiple Proxmox nodes
  nodes = flatten([
    for node_name, config in var.node_distribution : [
      # Control plane nodes for this Proxmox node
      for i in range(config.controlplane_count) : {
        key               = "controlplane-${node_name}-${i}"
        type              = "controlplane"
        proxmox_node_name = node_name
        name_prefix       = "${var.cluster_name}-ctrl"
        vm_id_min         = var.controlplane_vm_id_min
        vm_id_max         = var.controlplane_vm_id_max
        ip_start          = var.controlplane_ip_start
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
        name_prefix       = "${var.cluster_name}-node"
        vm_id_min         = var.worker_vm_id_min
        vm_id_max         = var.worker_vm_id_max
        ip_start          = var.worker_ip_start
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
}

# Random VM IDs for all nodes
resource "random_integer" "node_vm_id" {
  for_each = { for node in local.all_nodes : node.key => node }
  min      = each.value.vm_id_min
  max      = each.value.vm_id_max

  keepers = {
    cluster_name = var.cluster_name
  }
}

# All nodes (controlplane and worker)
resource "proxmox_virtual_environment_vm" "nodes" {
  for_each  = { for node in local.all_nodes : node.key => node }
  name      = "${each.value.name_prefix}-${random_integer.node_vm_id[each.key].result}"
  node_name = each.value.proxmox_node_name
  vm_id     = random_integer.node_vm_id[each.key].result
  tags      = concat(var.common_tags, [each.value.type])

  clone {
    vm_id = proxmox_virtual_environment_vm.template[each.value.template_key].vm_id
    full  = true
  }

  initialization {
    datastore_id = var.vm_datastore_id

    dynamic "ip_config" {
      for_each = var.enable_dhcp ? [] : [1]
      content {
        ipv4 {
          address = "${cidrhost(var.network_cidr, each.value.ip_start + each.value.global_index)}/${local.network_mask}"
          gateway = var.network_gateway
        }
      }
    }

    dns {
      servers = var.dns_servers
    }
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    proxmox_virtual_environment_vm.template
  ]
}
