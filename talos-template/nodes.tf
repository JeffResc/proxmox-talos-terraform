# Random VM IDs for control plane nodes
resource "random_integer" "controlplane_vm_id" {
  count = var.controlplane_count
  min   = 2000
  max   = 2999
  
  keepers = {
    index = count.index
  }
}

# Control plane nodes
resource "proxmox_virtual_environment_vm" "controlplane_nodes" {
  count     = var.controlplane_count
  name      = "talos-cp-${random_integer.controlplane_vm_id[count.index].result}"
  node_name = var.node_name
  vm_id     = random_integer.controlplane_vm_id[count.index].result
  
  clone {
    vm_id = proxmox_virtual_environment_vm.controlplane_template.vm_id
  }
  
  initialization {
    datastore_id = var.vm_datastore_id
    
    user_data_file_id = proxmox_virtual_environment_file.controlplane_node_cloud_init[count.index].id
    
    ip_config {
      ipv4 {
        address = "${cidrhost(var.network_cidr, var.controlplane_ip_start + count.index)}/${local.network_mask}"
        gateway = var.network_gateway
      }
    }
    
    dns {
      servers = var.dns_servers
    }
  }
  
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      proxmox_virtual_environment_vm.controlplane_template.id
    ]
  }
  
  depends_on = [
    proxmox_virtual_environment_vm.controlplane_template,
    proxmox_virtual_environment_file.controlplane_node_cloud_init
  ]
}

# Random VM IDs for worker nodes
resource "random_integer" "worker_vm_id" {
  count = var.worker_count
  min   = 3000
  max   = 3999
  
  keepers = {
    index = count.index
  }
}

# Worker nodes
resource "proxmox_virtual_environment_vm" "worker_nodes" {
  count     = var.worker_count
  name      = "talos-worker-${random_integer.worker_vm_id[count.index].result}"
  node_name = var.node_name
  vm_id     = random_integer.worker_vm_id[count.index].result
  
  clone {
    vm_id = proxmox_virtual_environment_vm.worker_template.vm_id
  }
  
  initialization {
    datastore_id = var.vm_datastore_id
    
    user_data_file_id = proxmox_virtual_environment_file.worker_node_cloud_init[count.index].id
    
    ip_config {
      ipv4 {
        address = "${cidrhost(var.network_cidr, var.worker_ip_start + count.index)}/${local.network_mask}"
        gateway = var.network_gateway
      }
    }
    
    dns {
      servers = var.dns_servers
    }
  }
  
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      proxmox_virtual_environment_vm.worker_template.id
    ]
  }
  
  depends_on = [
    proxmox_virtual_environment_vm.worker_template,
    proxmox_virtual_environment_file.worker_node_cloud_init
  ]
}