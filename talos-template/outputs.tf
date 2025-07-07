output "controlplane_nodes" {
  description = "Control plane node information"
  value = {
    for i in range(var.controlplane_count) : "talos-cp-${i + 1}" => {
      vm_id      = proxmox_virtual_environment_vm.controlplane_nodes[i].vm_id
      ip_address = cidrhost(var.network_cidr, var.controlplane_ip_start + i)
      name       = proxmox_virtual_environment_vm.controlplane_nodes[i].name
    }
  }
}

output "worker_nodes" {
  description = "Worker node information"
  value = {
    for i in range(var.worker_count) : "talos-worker-${i + 1}" => {
      vm_id      = proxmox_virtual_environment_vm.worker_nodes[i].vm_id
      ip_address = cidrhost(var.network_cidr, var.worker_ip_start + i)
      name       = proxmox_virtual_environment_vm.worker_nodes[i].name
    }
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
  value       = proxmox_virtual_environment_vm.controlplane_template.vm_id
}

output "worker_template_id" {
  description = "Worker template VM ID"
  value       = proxmox_virtual_environment_vm.worker_template.vm_id
}

output "talos_machine_secrets" {
  description = "Talos machine secrets (sensitive)"
  value       = talos_machine_secrets.this.machine_secrets
  sensitive   = true
}

output "controlplane_ips" {
  description = "List of control plane IP addresses"
  value       = [for i in range(var.controlplane_count) : cidrhost(var.network_cidr, var.controlplane_ip_start + i)]
}

output "worker_ips" {
  description = "List of worker IP addresses"
  value       = [for i in range(var.worker_count) : cidrhost(var.network_cidr, var.worker_ip_start + i)]
}

output "talos_client_configuration" {
  description = "Complete Talos client configuration for ~/.talos/config"
  value = templatefile("${path.module}/talos-client-config.yaml", {
    cluster_name       = var.cluster_name
    talos_endpoint     = "${regex("https?://([^:]+)", var.cluster_endpoint)[0]}:50000"
    node_ips           = [for i in range(var.controlplane_count) : cidrhost(var.network_cidr, var.controlplane_ip_start + i)]
    ca_certificate     = talos_machine_secrets.this.client_configuration.ca_certificate
    client_certificate = talos_machine_secrets.this.client_configuration.client_certificate
    client_key         = talos_machine_secrets.this.client_configuration.client_key
  })
  sensitive = true
}