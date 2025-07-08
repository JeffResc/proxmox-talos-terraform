# Download Talos image
resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "import"
  datastore_id = var.talos_disk_image_datastore_id
  node_name    = var.image_download_node
  file_name    = var.talos_image_filename
  url          = "https://factory.talos.dev/image/${var.schematic_id}/${var.talos_version}/nocloud-amd64.qcow2"
  overwrite    = true
}

# VM Templates
resource "proxmox_virtual_environment_vm" "template" {
  for_each = {
    controlplane = {
      name      = "${var.cluster_name}-ctrl-${var.talos_version}"
      vm_id     = var.controlplane_template_id
      tag       = "controlplane"
      memory    = var.controlplane_memory
      cpu_cores = var.controlplane_cpu_cores
      disk_size = var.controlplane_disk_size
    }
    worker = {
      name      = "${var.cluster_name}-node-${var.talos_version}"
      vm_id     = var.worker_template_id
      tag       = "worker"
      memory    = var.worker_memory
      cpu_cores = var.worker_cpu_cores
      disk_size = var.worker_disk_size
    }
  }

  name      = each.value.name
  node_name = var.template_node
  vm_id     = each.value.vm_id
  template  = true
  tags      = concat(var.common_tags, var.extra_tags, [each.value.tag])

  disk {
    datastore_id = var.template_datastore_id
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
    type  = var.cpu_type
  }

  network_device {
    bridge = var.network_bridge
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

# Node configuration
locals {
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

  # Network configuration
  network_mask = var.enable_dhcp || var.network_cidr == null || var.network_cidr == "" ? null : split("/", var.network_cidr)[1]
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
  tags      = concat(var.common_tags, var.extra_tags, [each.value.type])

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
