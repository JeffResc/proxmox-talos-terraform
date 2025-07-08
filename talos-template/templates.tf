# VM Templates
resource "proxmox_virtual_environment_vm" "controlplane_template" {
  name      = local.controlplane_template_name
  node_name = var.node_name
  vm_id     = local.controlplane_template_id
  template  = true
  tags      = concat(local.common_tags, ["controlplane"])

  disk {
    datastore_id = var.template_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = local.controlplane_disk_size
  }

  # Higher resources for control plane
  memory {
    dedicated = local.controlplane_memory
    floating  = local.controlplane_memory
  }

  cpu {
    cores = local.controlplane_cpu_cores
    type  = local.cpu_type
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

}

resource "proxmox_virtual_environment_vm" "worker_template" {
  name      = local.worker_template_name
  node_name = var.node_name
  vm_id     = local.worker_template_id
  template  = true
  tags      = concat(local.common_tags, ["worker"])

  disk {
    datastore_id = var.template_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = local.worker_disk_size
  }


  # Resources optimized for workloads
  memory {
    dedicated = local.worker_memory
    floating  = local.worker_memory
  }

  cpu {
    cores = local.worker_cpu_cores
    type  = local.cpu_type
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

}