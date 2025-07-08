locals {
  # Network configuration
  network_mask = split("/", var.network_cidr)[1]

  # Cluster endpoint computation
  cluster_endpoint = var.cluster_vip_enabled ? "https://${var.cluster_vip_ip}:6443" : var.cluster_endpoint_override

  # File names
  talos_image_filename = "${var.cluster_name}-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.qcow2"

  # Template names
  controlplane_template_name = "${var.cluster_name}-ctrl-${var.talos_version}"
  worker_template_name       = "${var.cluster_name}-node-${var.talos_version}"
}
