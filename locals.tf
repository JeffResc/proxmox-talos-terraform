locals {
  # Common tags for all resources
  common_tags = ["talos", "terraform"]

  # VM IDs
  controlplane_template_id = 998
  worker_template_id       = 999
  controlplane_vm_id_start = 2000
  worker_vm_id_start       = 3000

  # Disk sizes
  controlplane_disk_size = 20
  worker_disk_size       = 50

  # Memory configurations (in MB)
  controlplane_memory = var.controlplane_memory
  worker_memory       = var.worker_memory

  # CPU configurations
  controlplane_cpu_cores = var.controlplane_cpu_cores
  worker_cpu_cores       = var.worker_cpu_cores
  cpu_type               = var.cpu_type

  # Network configuration
  network_bridge = "vmbr0"
  network_mask   = split("/", var.network_cidr)[1]

  # File names
  talos_image_filename = "${var.cluster_name}-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.qcow2"

  # Template names
  controlplane_template_name = "${var.cluster_name}-ctrl-${var.talos_version}"
  worker_template_name       = "${var.cluster_name}-node-${var.talos_version}"
}