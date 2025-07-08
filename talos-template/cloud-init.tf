# Node-specific cloud-init configurations
resource "proxmox_virtual_environment_file" "controlplane_node_cloud_init" {
  count        = var.controlplane_count
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name
  
  source_raw {
    data = templatefile("${path.module}/cloud-init-template.yaml", {
      talos_config = base64encode(data.talos_machine_configuration.controlplane_nodes[count.index].machine_configuration)
    })
    
    file_name = "talos-cp-${count.index + 1}-cloud-init.yaml"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "proxmox_virtual_environment_file" "worker_node_cloud_init" {
  count        = var.worker_count
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name
  
  source_raw {
    data = templatefile("${path.module}/cloud-init-template.yaml", {
      talos_config = base64encode(data.talos_machine_configuration.worker_nodes[count.index].machine_configuration)
    })
    
    file_name = "talos-worker-${count.index + 1}-cloud-init.yaml"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}