# Random VM IDs for control plane nodes
resource "random_integer" "controlplane_vm_id" {
  count = var.controlplane_count
  min   = var.controlplane_vm_id_min
  max   = var.controlplane_vm_id_max

  keepers = {
    # Only regenerate VM ID when template changes
    template_id = proxmox_virtual_environment_vm.template["controlplane"].id
  }
}

# Control plane nodes
resource "proxmox_virtual_environment_vm" "controlplane_nodes" {
  count     = var.controlplane_count
  name      = "talos-cp-${random_integer.controlplane_vm_id[count.index].result}"
  node_name = var.node_name
  vm_id     = random_integer.controlplane_vm_id[count.index].result

  clone {
    vm_id = proxmox_virtual_environment_vm.template["controlplane"].vm_id
    full  = true
  }

  initialization {
    datastore_id = var.vm_datastore_id


    dynamic "ip_config" {
      for_each = var.enable_dhcp ? [] : [1]
      content {
        ipv4 {
          address = "${cidrhost(var.network_cidr, var.controlplane_ip_start + count.index)}/${local.network_mask}"
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
    ignore_changes        = [name, vm_id]
  }

  depends_on = [
    proxmox_virtual_environment_vm.template["controlplane"]
  ]
}

# Random VM IDs for worker nodes
resource "random_integer" "worker_vm_id" {
  count = var.worker_count
  min   = var.worker_vm_id_min
  max   = var.worker_vm_id_max

  keepers = {
    # Only regenerate VM ID when template changes
    template_id = proxmox_virtual_environment_vm.template["worker"].id
  }
}

# Worker nodes
resource "proxmox_virtual_environment_vm" "worker_nodes" {
  count     = var.worker_count
  name      = "talos-worker-${random_integer.worker_vm_id[count.index].result}"
  node_name = var.node_name
  vm_id     = random_integer.worker_vm_id[count.index].result

  clone {
    vm_id = proxmox_virtual_environment_vm.template["worker"].vm_id
    full  = true
  }

  initialization {
    datastore_id = var.vm_datastore_id


    dynamic "ip_config" {
      for_each = var.enable_dhcp ? [] : [1]
      content {
        ipv4 {
          address = "${cidrhost(var.network_cidr, var.worker_ip_start + count.index)}/${local.network_mask}"
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
    ignore_changes        = [name, vm_id]
  }

  depends_on = [
    proxmox_virtual_environment_vm.template["worker"]
  ]
}