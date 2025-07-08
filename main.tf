# Main configuration file
# This file demonstrates how to use the Talos Proxmox modules together
# All variables are available at the root level for easy customization

# Proxmox Cloud Controller Manager
module "proxmox_ccm" {
  source = "./modules/proxmox-ccm"

  proxmox_ccm_user = var.proxmox_ccm_user
  proxmox_ccm_role = var.proxmox_ccm_role
}

# Talos bootstrap and configuration
module "talos_bootstrap" {
  source = "./modules/talos-bootstrap"

  # Talos configuration
  talos_version             = var.talos_version
  cluster_name              = var.cluster_name
  cluster_vip_enabled       = var.cluster_vip_enabled
  cluster_vip_ip            = var.cluster_vip_ip
  cluster_endpoint_override = var.cluster_endpoint_override
  network_interface         = var.network_interface
  enable_dhcp               = var.enable_dhcp

  # Proxmox configuration
  proxmox_endpoint  = var.proxmox_endpoint
  proxmox_insecure  = var.proxmox_insecure

  # Values from other modules
  ccm_token_id                = module.proxmox_ccm.ccm_token_id
  ccm_token_secret            = module.proxmox_ccm.ccm_token_secret
  controlplane_nodes          = module.proxmox_infrastructure.controlplane_nodes
  worker_nodes                = module.proxmox_infrastructure.worker_nodes
  first_controlplane_endpoint = module.proxmox_infrastructure.first_controlplane_endpoint
  first_controlplane_node     = module.proxmox_infrastructure.first_controlplane_node
  nodes_ready                 = module.proxmox_infrastructure.nodes
}

# Proxmox infrastructure (VMs, templates, etc.)
module "proxmox_infrastructure" {
  source = "./modules/proxmox-infrastructure"

  # Cluster configuration
  cluster_name  = var.cluster_name
  talos_version = var.talos_version

  # Network configuration
  network_cidr            = var.network_cidr
  network_gateway         = var.network_gateway
  network_interface       = var.network_interface
  network_bridge          = var.network_bridge
  enable_dhcp             = var.enable_dhcp
  dns_servers             = var.dns_servers
  controlplane_ip_start   = var.controlplane_ip_start
  worker_ip_start         = var.worker_ip_start

  # Infrastructure configuration
  node_distribution    = var.node_distribution
  template_node        = var.template_node
  image_download_node  = var.image_download_node

  # Datastore configuration
  talos_disk_image_datastore_id = var.talos_disk_image_datastore_id
  template_datastore_id         = var.template_datastore_id
  vm_datastore_id               = var.vm_datastore_id

  # VM template configuration
  controlplane_template_id = var.controlplane_template_id
  worker_template_id       = var.worker_template_id

  # VM resource configuration
  controlplane_memory    = var.controlplane_memory
  worker_memory          = var.worker_memory
  controlplane_cpu_cores = var.controlplane_cpu_cores
  worker_cpu_cores       = var.worker_cpu_cores
  controlplane_disk_size = var.controlplane_disk_size
  worker_disk_size       = var.worker_disk_size
  cpu_type               = var.cpu_type

  # VM ID ranges
  controlplane_vm_id_min = var.controlplane_vm_id_min
  controlplane_vm_id_max = var.controlplane_vm_id_max
  worker_vm_id_min       = var.worker_vm_id_min
  worker_vm_id_max       = var.worker_vm_id_max

  # Tagging configuration
  common_tags = var.common_tags
  extra_tags  = var.extra_tags

  # Values from other modules
  schematic_id         = module.talos_bootstrap.image_factory_schematic_id
  talos_image_filename = module.talos_bootstrap.talos_image_filename
}