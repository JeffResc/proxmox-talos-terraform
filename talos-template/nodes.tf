# Node configuration
locals {
  node_configs = {
    controlplane = {
      count        = var.controlplane_count
      name_prefix  = "talos-cp"
      vm_id_min    = var.controlplane_vm_id_min
      vm_id_max    = var.controlplane_vm_id_max
      ip_start     = var.controlplane_ip_start
      template_key = "controlplane"
    }
    worker = {
      count        = var.worker_count
      name_prefix  = "talos-wrkr"
      vm_id_min    = var.worker_vm_id_min
      vm_id_max    = var.worker_vm_id_max
      ip_start     = var.worker_ip_start
      template_key = "worker"
    }
  }

  # Flatten node configurations for iteration
  nodes = flatten([
    for node_type, config in local.node_configs : [
      for i in range(config.count) : {
        key          = "${node_type}-${i}"
        type         = node_type
        name_prefix  = config.name_prefix
        vm_id_min    = config.vm_id_min
        vm_id_max    = config.vm_id_max
        ip_start     = config.ip_start
        template_key = config.template_key
        index        = i
      }
    ] if config.count > 0
  ])
}

# Random VM IDs for all nodes
resource "random_integer" "node_vm_id" {
  for_each = { for node in local.nodes : node.key => node }
  min      = each.value.vm_id_min
  max      = each.value.vm_id_max

  keepers = {
    cluster_name = var.cluster_name
  }
}

# All nodes (controlplane and worker)
resource "proxmox_virtual_environment_vm" "nodes" {
  for_each  = { for node in local.nodes : node.key => node }
  name      = "${each.value.name_prefix}-${random_integer.node_vm_id[each.key].result}"
  node_name = var.node_name
  vm_id     = random_integer.node_vm_id[each.key].result

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
          address = "${cidrhost(var.network_cidr, each.value.ip_start + each.value.index)}/${local.network_mask}"
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
