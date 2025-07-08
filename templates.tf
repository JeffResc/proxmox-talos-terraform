# VM Templates
resource "proxmox_virtual_environment_vm" "template" {
  for_each = {
    controlplane = {
      name      = local.controlplane_template_name
      vm_id     = var.controlplane_template_id
      tag       = "controlplane"
      memory    = var.controlplane_memory
      cpu_cores = var.controlplane_cpu_cores
      disk_size = var.controlplane_disk_size
    }
    worker = {
      name      = local.worker_template_name
      vm_id     = var.worker_template_id
      tag       = "worker"
      memory    = var.worker_memory
      cpu_cores = var.worker_cpu_cores
      disk_size = var.worker_disk_size
    }
  }

  name      = each.value.name
  node_name = var.node_name
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
