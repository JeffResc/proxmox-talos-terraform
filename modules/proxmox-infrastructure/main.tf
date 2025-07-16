# Download Talos image
resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "import"
  datastore_id = var.proxmox_config.talos_disk_image_datastore_id
  node_name    = var.proxmox_config.node_name
  file_name    = var.talos_image_config.filename
  url          = "https://factory.talos.dev/image/${var.talos_image_config.schematic_id}/${var.cluster_config.talos_version}/nocloud-amd64.qcow2"
  overwrite    = true
}

# VM Templates
resource "proxmox_virtual_environment_vm" "template" {
  for_each = {
    controlplane = {
      name      = "${var.cluster_config.name}-ctrl-${var.cluster_config.talos_version}"
      vm_id     = var.template_config.controlplane_id
      tag       = "controlplane"
      memory    = var.resource_config.controlplane.memory
      cpu_cores = var.resource_config.controlplane.cpu_cores
      disk_size = var.resource_config.controlplane.disk_size
    }
    worker = {
      name      = "${var.cluster_config.name}-node-${var.cluster_config.talos_version}"
      vm_id     = var.template_config.worker_id
      tag       = "worker"
      memory    = var.resource_config.worker.memory
      cpu_cores = var.resource_config.worker.cpu_cores
      disk_size = var.resource_config.worker.disk_size
    }
  }

  name      = each.value.name
  node_name = var.proxmox_config.node_name
  vm_id     = each.value.vm_id
  template  = true
  tags      = concat(var.tagging_config.common, var.tagging_config.extra, [each.value.tag])

  # Add to resource pool if network configuration is provided
  pool_id = var.network_configuration != null ? var.network_configuration.resource_pool_id : null

  disk {
    datastore_id = var.proxmox_config.template_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  cpu {
    cores = each.value.cpu_cores
    type  = var.resource_config.cpu_type
  }

  network_device {
    bridge = var.network_configuration != null ? var.network_configuration.bridge_name : var.network_config.bridge
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  lifecycle {
    replace_triggered_by = [
      proxmox_virtual_environment_download_file.talos_image.id
    ]
  }
}

# Node configuration handled in locals.tf

# Random VM IDs for all nodes
resource "random_integer" "node_vm_id" {
  for_each = { for node in local.all_nodes : node.key => node }
  min      = each.value.vm_id_min
  max      = each.value.vm_id_max

  keepers = {
    cluster_name = var.cluster_config.name
  }
}

# All nodes (controlplane and worker)
resource "proxmox_virtual_environment_vm" "nodes" {
  for_each  = { for node in local.all_nodes : node.key => node }
  name      = "${each.value.name_prefix}-${random_integer.node_vm_id[each.key].result}"
  node_name = each.value.proxmox_node_name
  vm_id     = random_integer.node_vm_id[each.key].result
  tags      = concat(var.tagging_config.common, var.tagging_config.extra, [each.value.type])

  # Add to resource pool if network configuration is provided
  pool_id = var.network_configuration != null ? var.network_configuration.resource_pool_id : null

  clone {
    vm_id = proxmox_virtual_environment_vm.template[each.value.template_key].vm_id
    full  = true
  }

  initialization {
    datastore_id = var.proxmox_config.vm_datastore_id

    dynamic "ip_config" {
      for_each = var.network_config.enable_dhcp ? [] : [1]
      content {
        ipv4 {
          address = "${local.node_ips[each.key]}/${element(split("/", var.network_config.cidr), 1)}"
          gateway = var.network_config.gateway
        }
      }
    }

    dns {
      servers = var.proxmox_config.dns_servers
    }
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    proxmox_virtual_environment_vm.template
  ]
}

# =============================================================================
# VM FIREWALL OPTIONS
# =============================================================================

# Configure firewall options for each VM
resource "proxmox_virtual_environment_firewall_options" "nodes" {
  for_each = var.network_config.enable_firewall && var.network_config.vm_firewall.enabled ? local.nodes_map : {}

  node_name = each.value.node
  vm_id     = proxmox_virtual_environment_vm.nodes[each.key].vm_id

  # Firewall settings
  enabled       = var.network_config.vm_firewall.enabled
  dhcp          = var.network_config.vm_firewall.dhcp
  ipfilter      = var.network_config.vm_firewall.ipfilter
  log_level_in  = var.network_config.vm_firewall.log_level_in
  log_level_out = var.network_config.vm_firewall.log_level_out
  macfilter     = var.network_config.vm_firewall.macfilter
  ndp           = var.network_config.vm_firewall.ndp

  # Default policies
  input_policy  = var.network_config.vm_firewall.input_policy
  output_policy = var.network_config.vm_firewall.output_policy

  depends_on = [
    proxmox_virtual_environment_vm.nodes
  ]
}
