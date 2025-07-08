output "controlplane_nodes" {
  description = "Control plane node information"
  value = {
    for k, v in module.proxmox_infrastructure.nodes : k => {
      vm_id      = v.vm_id
      ip_address = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      name       = v.name
    }
    if startswith(k, "controlplane-")
  }
}

output "worker_nodes" {
  description = "Worker node information"
  value = {
    for k, v in module.proxmox_infrastructure.nodes : k => {
      vm_id      = v.vm_id
      ip_address = v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
      name       = v.name
    }
    if startswith(k, "worker-")
  }
}

output "cluster_endpoint" {
  description = "Cluster endpoint URL"
  value       = var.cluster_config.vip.enabled ? "https://${var.cluster_config.vip.ip}:6443" : var.cluster_config.endpoint_override
}

output "talos_image_id" {
  description = "Talos image ID in Proxmox"
  value       = module.proxmox_infrastructure.talos_image.id
}

output "controlplane_template_id" {
  description = "Control plane template VM ID"
  value       = module.proxmox_infrastructure.templates["controlplane"].vm_id
}

output "worker_template_id" {
  description = "Worker template VM ID"
  value       = module.proxmox_infrastructure.templates["worker"].vm_id
}

output "talos_machine_secrets" {
  description = "Talos machine secrets (sensitive)"
  value       = module.talos_bootstrap.client_configuration
  sensitive   = true
}

output "controlplane_ips" {
  description = "List of control plane IP addresses"
  value = [
    for k, v in module.proxmox_infrastructure.nodes : v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
    if startswith(k, "controlplane-")
  ]
}

output "worker_ips" {
  description = "List of worker IP addresses"
  value = [
    for k, v in module.proxmox_infrastructure.nodes : v.ipv4_addresses[index(v.network_interface_names, var.network_config.interface)][0]
    if startswith(k, "worker-")
  ]
}

output "talos_client_configuration" {
  description = "Complete Talos client configuration for ~/.talos/config"
  value = templatefile("${path.module}/talos-client-config.yaml", {
    cluster_name       = var.cluster_config.name
    talos_endpoint     = "${regex("https?://([^:]+)", var.cluster_config.vip.enabled ? "https://${var.cluster_config.vip.ip}:6443" : var.cluster_config.endpoint_override)[0]}:50000"
    ca_certificate     = module.talos_bootstrap.client_configuration.ca_certificate
    client_certificate = module.talos_bootstrap.client_configuration.client_certificate
    client_key         = module.talos_bootstrap.client_configuration.client_key
  })
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  description = "Talos cluster kubeconfig"
  value       = module.talos_bootstrap.kubeconfig
  sensitive   = true
}

output "proxmox_ccm_token" {
  description = "Proxmox Cloud Controller Manager API token"
  value       = module.proxmox_ccm.ccm_token.value
  sensitive   = true
}
