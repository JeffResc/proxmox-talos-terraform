# Main configuration file
# This file demonstrates how to use the Talos Proxmox modules together
# All variables are available at the root level for easy customization

# Proxmox Cloud Controller Manager
module "proxmox_ccm" {
  source = "./modules/proxmox-ccm"
  count  = var.proxmox_config.ccm_config.enabled ? 1 : 0

  ccm_config = var.proxmox_config.ccm_config
}

# Talos bootstrap and configuration
module "talos_bootstrap" {
  source = "./modules/talos-bootstrap"

  # Pass through shared variables
  talos_version             = var.cluster_config.talos_version
  cluster_name              = var.cluster_config.name
  cluster_vip_enabled       = var.cluster_config.vip.enabled
  cluster_vip_ip            = var.cluster_config.vip.ip
  cluster_endpoint_override = var.cluster_config.endpoint_override
  proxmox_endpoint          = var.proxmox_config.endpoint
  proxmox_insecure          = var.proxmox_config.insecure

  # Override defaults only if needed
  # network_interface = "ens18"
  # enable_dhcp = true

  # Values from other modules
  ccm_token_id                = var.proxmox_config.ccm_config.enabled ? module.proxmox_ccm[0].ccm_token_id : ""
  ccm_token_secret            = var.proxmox_config.ccm_config.enabled ? module.proxmox_ccm[0].ccm_token_secret : ""
  controlplane_nodes          = module.proxmox_infrastructure.controlplane_nodes
  worker_nodes                = module.proxmox_infrastructure.worker_nodes
  first_controlplane_endpoint = module.proxmox_infrastructure.first_controlplane_endpoint
  first_controlplane_node     = module.proxmox_infrastructure.first_controlplane_node
  nodes_ready                 = module.proxmox_infrastructure.nodes
}

# Proxmox infrastructure (VMs, templates, etc.)
module "proxmox_infrastructure" {
  source = "./modules/proxmox-infrastructure"

  # Pass through shared variables
  talos_version   = var.cluster_config.talos_version
  cluster_name    = var.cluster_config.name
  network_cidr    = var.network_config.cidr
  network_gateway = var.network_config.gateway

  # Pass through infrastructure variables
  talos_disk_image_datastore_id = var.proxmox_config.talos_disk_image_datastore_id
  template_datastore_id         = var.proxmox_config.template_datastore_id
  vm_datastore_id               = var.proxmox_config.vm_datastore_id
  network_bridge                = var.network_config.bridge
  controlplane_ip_start         = var.node_config.controlplane_ip_start
  worker_ip_start               = var.node_config.worker_ip_start
  dns_servers                   = var.proxmox_config.dns_servers

  # Node distribution configuration
  # Since we're using simple counts, we need to create the node_distribution
  node_distribution = var.node_distribution

  # Template configuration
  template_node            = var.template_config.node
  image_download_node      = var.template_config.node
  controlplane_template_id = var.template_config.controlplane_id
  worker_template_id       = var.template_config.worker_id

  # Resource configuration
  controlplane_memory    = var.resource_config.controlplane.memory
  worker_memory          = var.resource_config.worker.memory
  controlplane_cpu_cores = var.resource_config.controlplane.cpu_cores
  worker_cpu_cores       = var.resource_config.worker.cpu_cores
  controlplane_disk_size = var.resource_config.controlplane.disk_size
  worker_disk_size       = var.resource_config.worker.disk_size
  cpu_type               = var.resource_config.cpu_type

  # VM ID ranges
  controlplane_vm_id_min = var.vm_id_ranges.controlplane_min
  controlplane_vm_id_max = var.vm_id_ranges.controlplane_max
  worker_vm_id_min       = var.vm_id_ranges.worker_min
  worker_vm_id_max       = var.vm_id_ranges.worker_max

  # Tagging
  common_tags = var.tagging_config.common
  extra_tags  = var.tagging_config.extra

  # Override defaults only if needed
  # enable_dhcp = true

  # Values from other modules
  schematic_id         = module.talos_bootstrap.image_factory_schematic_id
  talos_image_filename = module.talos_bootstrap.talos_image_filename
}
