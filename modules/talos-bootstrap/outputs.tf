output "client_configuration" {
  description = "Talos client configuration"
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
}

output "talos_config" {
  description = "Talos configuration for talosctl"
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration for kubectl"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "controlplane_machine_configuration" {
  description = "Controlplane machine configuration"
  value       = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive   = true
}

output "worker_machine_configuration" {
  description = "Worker machine configuration"
  value       = data.talos_machine_configuration.worker.machine_configuration
  sensitive   = true
}

output "image_factory_schematic_id" {
  description = "Talos image factory schematic ID"
  value       = talos_image_factory_schematic.this.id
}

output "talos_image_filename" {
  description = "Talos image filename"
  value       = "${var.cluster_name}-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.qcow2"
}
