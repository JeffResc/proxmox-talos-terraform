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
  cloudinit_disk_size    = 4
  
  # Memory configurations (in MB)
  controlplane_memory = 4096
  worker_memory       = 8192
  
  # CPU configurations
  controlplane_cpu_cores = 4
  worker_cpu_cores       = 8
  cpu_type              = "x86-64-v2-AES"
  
  # Network configuration
  network_bridge = "vmbr0"
  network_mask   = split("/", var.network_cidr)[1]
  
  # File names
  talos_image_filename = "talos-${var.talos_version}-${talos_image_factory_schematic.this.id}-nocloud-amd64.qcow2"
  
  # Template names
  controlplane_template_name = "talos-controlplane-${var.talos_version}"
  worker_template_name       = "talos-worker-${var.talos_version}"
}