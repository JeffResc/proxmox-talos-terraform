# Control plane nodes
resource "proxmox_virtual_environment_vm" "controlplane_nodes" {
  count     = var.controlplane_count
  name      = "talos-cp-${count.index + 1}"
  node_name = var.node_name
  vm_id     = local.controlplane_vm_id_start + count.index
  
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
  }
  
  depends_on = [
    proxmox_virtual_environment_vm.controlplane_template,
    proxmox_virtual_environment_file.controlplane_node_cloud_init
  ]
}

# Worker nodes
resource "proxmox_virtual_environment_vm" "worker_nodes" {
  count     = var.worker_count
  name      = "talos-worker-${count.index + 1}"
  node_name = var.node_name
  vm_id     = local.worker_vm_id_start + count.index
  
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
  }
  
  depends_on = [
    proxmox_virtual_environment_vm.worker_template,
    proxmox_virtual_environment_file.worker_node_cloud_init
  ]
}