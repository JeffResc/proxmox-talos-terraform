locals {
  # Network configuration
  network_mask = split("/", var.network_cidr)[1]

  # File names
  talos_image_filename = "${var.cluster_name}-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.qcow2"

  # Template names
  controlplane_template_name = "${var.cluster_name}-ctrl-${var.talos_version}"
  worker_template_name       = "${var.cluster_name}-node-${var.talos_version}"
}
