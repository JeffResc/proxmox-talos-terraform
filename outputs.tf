output "controlplane_nodes" {
  description = "Control plane node information"
  value = {
    for k, v in proxmox_virtual_environment_vm.nodes : k => {
      vm_id      = v.vm_id
      ip_address = v.ipv4_addresses[index(v.network_interface_names, var.network_interface)][0]
      name       = v.name
    }
    if startswith(k, "controlplane-")
  }
}

output "worker_nodes" {
  description = "Worker node information"
  value = {
    for k, v in proxmox_virtual_environment_vm.nodes : k => {
      vm_id      = v.vm_id
      ip_address = v.ipv4_addresses[index(v.network_interface_names, var.network_interface)][0]
      name       = v.name
    }
    if startswith(k, "worker-")
  }
}

output "cluster_endpoint" {
  description = "Cluster endpoint URL"
  value       = var.cluster_endpoint
}

output "talos_image_id" {
  description = "Talos image ID in Proxmox"
  value       = proxmox_virtual_environment_download_file.talos_image.id
}

output "controlplane_template_id" {
  description = "Control plane template VM ID"
  value       = proxmox_virtual_environment_vm.template["controlplane"].vm_id
}

output "worker_template_id" {
  description = "Worker template VM ID"
  value       = proxmox_virtual_environment_vm.template["worker"].vm_id
}

output "talos_machine_secrets" {
  description = "Talos machine secrets (sensitive)"
  value       = talos_machine_secrets.this.machine_secrets
  sensitive   = true
}

output "controlplane_ips" {
  description = "List of control plane IP addresses"
  value = [
    for k, v in proxmox_virtual_environment_vm.nodes : v.ipv4_addresses[index(v.network_interface_names, var.network_interface)][0]
    if startswith(k, "controlplane-")
  ]
}

output "worker_ips" {
  description = "List of worker IP addresses"
  value = [
    for k, v in proxmox_virtual_environment_vm.nodes : v.ipv4_addresses[index(v.network_interface_names, var.network_interface)][0]
    if startswith(k, "worker-")
  ]
}

output "talos_client_configuration" {
  description = "Complete Talos client configuration for ~/.talos/config"
  value = templatefile("${path.module}/talos-client-config.yaml", {
    cluster_name       = var.cluster_name
    talos_endpoint     = "${regex("https?://([^:]+)", var.cluster_endpoint)[0]}:50000"
    ca_certificate     = talos_machine_secrets.this.client_configuration.ca_certificate
    client_certificate = talos_machine_secrets.this.client_configuration.client_certificate
    client_key         = talos_machine_secrets.this.client_configuration.client_key
  })
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  description = "Talos cluster kubeconfig"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "proxmox_ccm_token" {
  description = "Proxmox Cloud Controller Manager API token"
  value       = proxmox_virtual_environment_user_token.ccm.value
  sensitive   = true
}