# Main configuration file
# This file demonstrates how to use the Talos Proxmox modules together
# All variables are available at the root level for easy customization

# Proxmox Network Infrastructure (VPC-like networking)
module "proxmox_network" {
  source = "./modules/proxmox-network"
  count  = var.network_config.create_bridge != false || var.network_config.resource_pool_id != null ? 1 : 0

  cluster_config    = var.cluster_config
  network_config    = var.network_config
  node_distribution = var.node_distribution
}

# Proxmox Cloud Controller Manager
module "proxmox_ccm" {
  source = "./modules/proxmox-ccm"
  count  = var.proxmox_config.ccm_config.enabled ? 1 : 0

  ccm_config = var.proxmox_config.ccm_config
}

# Talos bootstrap and configuration
module "talos_bootstrap" {
  source = "./modules/talos-bootstrap"

  # Pass grouped configuration objects
  cluster_config = var.cluster_config
  network_config = var.network_config
  proxmox_config = var.proxmox_config

  # Node information from infrastructure module
  controlplane_nodes          = module.proxmox_infrastructure.controlplane_nodes
  worker_nodes                = module.proxmox_infrastructure.worker_nodes
  first_controlplane_endpoint = module.proxmox_infrastructure.first_controlplane_endpoint
  first_controlplane_node     = module.proxmox_infrastructure.first_controlplane_node
  nodes_ready                 = module.proxmox_infrastructure.nodes
}

# Proxmox infrastructure (VMs, templates, etc.)
module "proxmox_infrastructure" {
  source = "./modules/proxmox-infrastructure"

  # Pass grouped configuration objects directly from root
  cluster_config = var.cluster_config
  network_config = var.network_config
  proxmox_config = var.proxmox_config
  node_config    = var.node_config
  # Pass the other configuration objects
  node_distribution = var.node_distribution
  template_config   = var.template_config
  resource_config   = var.resource_config
  vm_id_ranges      = var.vm_id_ranges
  tagging_config    = var.tagging_config

  # Network configuration from network module (if created)
  network_configuration = length(module.proxmox_network) > 0 ? module.proxmox_network[0].network_configuration : null

  # Talos image configuration from bootstrap module
  talos_image_config = {
    schematic_id = module.talos_bootstrap.image_factory_schematic_id
    filename     = module.talos_bootstrap.talos_image_filename
  }
}
