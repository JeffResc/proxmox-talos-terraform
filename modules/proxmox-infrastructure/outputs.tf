output "nodes" {
  description = "All VM nodes (controlplane and worker)"
  value       = proxmox_virtual_environment_vm.nodes
}

output "controlplane_nodes" {
  description = "Map of controlplane nodes with their endpoints and VM IDs"
  value = {
    for k, v in proxmox_virtual_environment_vm.nodes : k => {
      endpoint = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      node     = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      vm_id    = tostring(v.vm_id)
    }
    if startswith(k, "controlplane-")
  }
}

output "worker_nodes" {
  description = "Map of worker nodes with their endpoints and VM IDs"
  value = {
    for k, v in proxmox_virtual_environment_vm.nodes : k => {
      endpoint = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      node     = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      vm_id    = tostring(v.vm_id)
    }
    if startswith(k, "worker-")
  }
}

output "first_controlplane_endpoint" {
  description = "Endpoint of the first controlplane node"
  value = values({
    for k, v in proxmox_virtual_environment_vm.nodes : k => v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
    if startswith(k, "controlplane-")
  })[0]
}

output "first_controlplane_node" {
  description = "Node address of the first controlplane node"
  value = values({
    for k, v in proxmox_virtual_environment_vm.nodes : k => v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
    if startswith(k, "controlplane-")
  })[0]
}

output "templates" {
  description = "VM templates"
  value       = proxmox_virtual_environment_vm.template
}

output "talos_image" {
  description = "Downloaded Talos image"
  value       = proxmox_virtual_environment_download_file.talos_image
}
